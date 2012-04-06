/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001-2003 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.numerics;

import spiritd.match;
import spiritd.nil;
import spiritd.parser;
import spiritd.primitives;
import spiritd.scanner;
import spiritd.composite.directives;
import spiritd.impl.debugging;
import spiritd.impl.directives;
import spiritd.impl.numerics;

/**\brief class to parse unsigned numbers */
class uintParser(T, int radix, uint minDig, int maxDig) : parser!(uintParser!(T, radix, minDig, maxDig)) {
	alias	typeof(this)	_thisT;

	/// we'll have a match result with a payload of the numberic type pls
	template	result(scannerT) {
		alias	matchResult!(scannerT, T)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		/// forward the parsing to contiguousParser with the actual impl, to perform no skip parsing
		alias	uintParserImpl!(T, radix, minDig, maxDig)	implT;
		alias	uintParserImpl!(T, radix, minDig, maxDig).result!(scannerT)._resultT	resultT;
		scope	up = new implT;
		return contiguousParserParse!(resultT)(up, s);
	}
}

/**\brief class to parse signed numbers */
class intParser(T, int radix, uint minDig, int maxDig) : parser!(intParser!(T, radix, minDig, maxDig)) {
	alias	typeof(this)	_thisT;

	/// we'll have a match result with a payload of the numberic type pls
	template	result(scannerT) {
		alias	matchResult!(scannerT, T)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		/// forward the parsing to contiguousParser with the actual impl, to perform no skip parsing
		alias	intParserImpl!(T, radix, minDig, maxDig)	implT;
		alias	intParserImpl!(T, radix, minDig, maxDig).result!(scannerT)._resultT	resultT;
		scope	up = new implT;
		return contiguousParserParse!(resultT)(up, s);
	}
}

	intParser!(int, 10, 1, -1)		intP;
	uintParser!(uint, 10, 1, -1)	uintP;
	uintParser!(uint, 2, 1, -1)	binP;
	uintParser!(uint, 8, 1, -1)	octP;
	uintParser!(uint, 16, 1, -1)	hexP;

	static this() {
		intP = new intParser!(int, 10, 1, -1);
		uintP = new uintParser!(uint, 10, 1, -1);
		binP = new uintParser!(uint, 2, 1, -1);
		octP = new uintParser!(uint, 8, 1, -1);
		hexP = new uintParser!(uint, 16, 1, -1);
	}

class signParser : parser!(signParser) {
	alias	typeof(this)	_thisT;

	template	result(scannerT) {
		alias	matchResult!(scannerT, bool)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		if(!s.atEnd()) {
			scannerT._sizeT		length;
			scannerT._iteratorT	save = s.first;
			auto	neg = extractSign!(scannerT)(s, length);

			if(length)
				return s.createMatch(1, neg, save, s.first);
		}
		return conv!(parserResult!(_thisT, scannerT)._resultT)(s.noMatch());
	}
}

signParser	signP;

static this() {
	signP	= new signParser;
}

class urealParserPolicies(T) {
	enum {
		bAllowLeadingDot = true,
		bAllowTrailingDot = true,
		bRequireDot = false
	}

	alias	uintParser!(T, 10, 1, -1)	uintParserT;
	alias	intParser!(T, 10, 1, -1)	intParserT;

	static matchResult!(scannerT, nilT)._resultT
	parseSign(scannerT)(scannerT scan) { 
		return scan.noMatch(); 
	}

	static parserResult!(uintParserT, scannerT)._resultT
	parseN(scannerT)(scannerT scan) { 
		scope p = new uintParserT;
		return p.parse(scan); 
	}

	static parserResult!(chLit!(scannerT._valueT), scannerT)._resultT
	parseDot(scannerT)(scannerT scan) { 
		scope p = new chLit!(scannerT._valueT)('.');
		return p.parse(scan); 
	}

	static parserResult!(uintParserT, scannerT)._resultT
	parseFracN(scannerT)(scannerT scan) { 
		scope p = new uintParserT;
		return p.parse(scan); 
	}

	static parserResult!(chLit!(scannerT._valueT), scannerT)._resultT
	parseExp(scannerT)(scannerT scan) { 
		alias	parserResult!(chLit!(scannerT._valueT), scannerT)._resultT	resultT;
		scope p = asLowerD[cast(scannerT._valueT)'e'];
		return conv!(resultT)(p.parse(scan)); 
	}

	static parserResult!(intParserT, scannerT)._resultT
	parseExpN(scannerT)(scannerT scan) { 
		scope p = new intParserT;
		return p.parse(scan); 
	}
}

class realParserPolicies(T) : urealParserPolicies!(T) {
	static parserResult!(signParser, scannerT)._resultT
	parseSign(scannerT)(scannerT s) { 
		return signP.parse(s); 
	}
}

class realParser(T, realPoliciesT) : parser!(realParser!(T, realPoliciesT)) {
	alias	typeof(this)	_thisT;

	template	result(scannerT) {
		alias	matchResult!(scannerT, T)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias parserResult!(_thisT, scannerT)._resultT	resultT;
		scope impl = new realParserImpl!(resultT, T, realPoliciesT);
		return impl.parse(s);
	}
}

	realParser!(double, urealParserPolicies!(double))	urealP;
	realParser!(double, realParserPolicies!(double))	realP;
		
	static this() {
		urealP = new realParser!(double, urealParserPolicies!(double));
		realP = new realParser!(double, realParserPolicies!(double));
	}

class strictUrealParserPolicies(T) : urealParserPolicies!(T) {
	enum { bRequireDot = true }
}

class strictRealParserPolicies(T) : realParserPolicies!(T) {
	enum { bRequireDot = true }
}

	realParser!(double, strictUrealParserPolicies!(double))	strictUrealP;
	realParser!(double, strictRealParserPolicies!(double))		strictRealP;

	static this() {
		strictUrealP	= new realParser!(double, strictUrealParserPolicies!(double));
		strictRealP		= new realParser!(double, strictRealParserPolicies!(double));
	}
