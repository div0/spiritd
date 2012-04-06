/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001-2003 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.numerics;

import std.math;

import spiritd.match;
import spiritd.numerics;
import spiritd.parser;
import spiritd.primitives;
import spiritd.scanner;
import spiritd.impl.ctype;
import spiritd.impl.directives;

template radixTraits(int radix : 2) {
	bool digit(charT, T)(charT ch, ref T val) {
		val = cast(charT)(ch - '0');
		return '0' == ch || '1' == ch;
	}
}

template radixTraits(int radix : 8) {
	bool digit(charT, T)(charT ch, ref T val) {
		val = cast(charT)(ch - '0');
		return '0' <= ch && ch <= '7';
	}
}

template radixTraits(int radix : 10) {
	bool digit(charT, T)(charT ch, ref T val) {
		val = cast(charT)(ch - '0');
		return '0' <= ch && ch <= '9';
	}
}

template radixTraits(int radix : 16) {
	bool digit(charT, T)(charT ch, ref T val) {
		if(radixTraits!(10).digit(ch, val))
			return true;
		charT	l = cast(charT)(tolower(ch));
		if(l < 'a' || l > 'f')
			return false;
		val = cast(charT)(l - 'a' + 10);
		return true;
	}
}

template extractSign(scannerT) {
	bool extractSign(scannerT s, ref scannerT._sizeT count) {
		count = 0;
		bool neg = s.get() == '-';

		if(neg || (s.get() == '+')) {
			s++;
			++count;
			return neg;
		}
		return false;
	}
}

template positiveAccumulate(T, int radix) {
	bool add(ref T n, T digit) {
		const maxDivRadix = T.max / radix;

		if(n > maxDivRadix)
			return false;
		n *= radix;
		if(n > T.max - digit)
			return false;
		n += digit;
		return true;
	}
}

template negativeAccumulate(T, int radix) {
version(D_Version2) {
	bool add(ref T n, T digit) {
		enum {
			isInteger = __traits(isIntegral, T),
			isSigned = !__traits(isUnsigned, T),
			hasDenorm = __traits(isFloating, T),
		}
		const min = (!isInteger && isSigned && hasDenorm) ? -T.max : T.min;
		const minDivRadix = min / radix;

		if(n < minDivRadix)
			return false;
		n *= radix;

		if(n < min + digit)
			return false;
		n -= digit;
		return true;
	}
} else {
	bool add(ref T n, T digit) {
//pragma (msg, __FILE__ ": template negativeAccumulate(...).add: need a D1 solution here.")
		n *= radix;
		n -= digit;
		return true;
	}
}
}

bool allowMoreDigits(int maxDig, sizeT)(sizeT i)		{ return i < maxDig; }
bool allowMoreDigits(int maxDig : -1, sizeT)(sizeT i)	{ return true; }

template extractInt(int radix, uint minDig, int maxDig, alias Accumulate, scannerT, T) {
	bool extractInt(scannerT s, ref T n, ref scannerT._sizeT count) {
		scannerT._sizeT		i;
		T					digit = 0; // explicit initialisation! T maybe float/double
		while(allowMoreDigits!(maxDig)(i) && !s.atEnd() && radixTraits!(radix).digit(s.get(), digit)) {
			if( !Accumulate.add(n, digit) )
				return false;
			++i, s++, ++count;
		}
		return i >= minDig;
	}
}

/**\brief impl of uint parser */
class uintParserImpl(T, int radix, uint minDig, int maxDig) : parser!(uintParserImpl!(T, radix, minDig, maxDig)) {
	alias	typeof(this)	_thisT;

	/// we'll have a match result with a payload of the numberic type pls
	template	result(scannerT) {
		alias	matchResult!(scannerT, T)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		if(!s.atEnd()) {
			T				n = 0; // explicit initialisation! T maybe float/double
			s._sizeT		count;
			s._iteratorT	save = s.first;

			if(extractInt!(radix, minDig, maxDig, positiveAccumulate!(T, radix), scannerT, T)(s, n, count))
				return s.createMatch(count, n, save, s.first);
		}
		return conv!(result!(scannerT)._resultT)(s.noMatch());
	}
}

/**\brief impl of int parser */
class intParserImpl(T, int radix, uint minDig, int maxDig) : parser!(intParserImpl!(T, radix, minDig, maxDig)) {
	alias	typeof(this)	_thisT;

	/// we'll have a match result with a payload of the numberic type pls
	template	result(scannerT) {
		alias	matchResult!(scannerT, T)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	extractInt!(radix, minDig, maxDig, negativeAccumulate!(T, radix), scannerT, T)		extractIntNegT;
		alias	extractInt!(radix, minDig, maxDig, positiveAccumulate!(T, radix), scannerT, T)		extractIntPosT;

		if(!s.atEnd()) {
			T				n = 0; // explicit initialisation! T maybe float/double
			s._sizeT		count;
			s._iteratorT	save = s.first;

			bool hit = extractSign!(scannerT)(s, count);

			if(hit)
				hit = extractIntNegT(s, n, count);
			else
				hit = extractIntPosT(s, n, count);

			if(hit)
				return s.createMatch(count, n, save, s.first);
			s.first = save;
		}
		return conv!(result!(scannerT)._resultT)(s.noMatch());
	}
}

/**\brief impl of real parser */
class realParserImpl(resultT, T, realPoliciesT) {
	alias	typeof(this)	_thisT;

	resultT parseMain(scannerT)(scannerT s) {
		if(s.atEnd())
			return conv!(resultT)(s.noMatch());

		alias	parserResult!(signParser, scannerT)._resultT					signMatchT;
		alias	parserResult!(chLit!(scannerT._valueT), scannerT)._resultT		expMatchT;

		s._iteratorT	save = s.first;
		signMatchT		signMatch = realPoliciesT.parseSign(s);
		s._sizeT		count = signMatch.match ? signMatch.length : 0;
		bool			neg = signMatch.match ? signMatch.value : false;
		resultT			nMatch = realPoliciesT.parseN(s);
		T				n = nMatch.match ? nMatch.value : 0;
		bool			gotANumber = nMatch.match;
		expMatchT		eHit;

		if(!gotANumber && !realPoliciesT.bAllowLeadingDot)
			return conv!(resultT)(s.noMatch());

		count += nMatch.length;

		if(neg)
			n = -n;

		auto parseDotMatch = realPoliciesT.parseDot(s);
		if(parseDotMatch.match)
		{
			//  We got the decimal point. Now we will try to parse
			//  the fraction if it is there. If not, it defaults
			//  to zero (0) only if we already got a number.
			resultT		hit = realPoliciesT.parseFracN(s);
			if(hit.match) {
				hit.value = hit.value * pow(10., cast(double)-hit.length);

				if(neg)
					n -= hit.value;
				else
					n += hit.value;
				count += hit.length + 1;

			} else if(!gotANumber || !realPoliciesT.bAllowTrailingDot)
				return conv!(resultT)(s.noMatch());

			eHit = realPoliciesT.parseExp(s);
		} else {
			// no number? bail
			if(!gotANumber)
				return conv!(resultT)(s.noMatch());

			eHit = realPoliciesT.parseExp(s);

			if(realPoliciesT.bRequireDot && !eHit.match)
				return conv!(resultT)(s.noMatch());
		}

		if(eHit.match) {
			resultT	enHit = realPoliciesT.parseExpN(s);

			if(!enHit.match)
				return conv!(resultT)(s.noMatch());

			n *= pow(10., cast(double)enHit.value);
			count += enHit.length + eHit.length;
		}

		return s.createMatch(count, n, save, s.first);
	}

	 resultT parse(scannerT)(scannerT s) {
		return implicitLexemeParse!(resultT)(this, s);
	}
}
