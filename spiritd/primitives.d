/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2003 Martin Wille

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.primitives;

import spiritd.match;
import spiritd.nil;
import spiritd.parser;
import spiritd.scanner;
import spiritd.impl.ctype;
import spiritd.impl.debugging;
import impl0 = spiritd.impl.directives;
import impl1 = spiritd.impl.primitives;

/**\brief base class for character parsers */
class charParser(derivingT) : parser!(derivingT) {
	alias	typeof(this)		_thisT;

	template	result(scannerT) {
		alias	matchResult!(scannerT, scannerT._valueT)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	scannerT._valueT		valueT;
		alias	scannerT._iteratorT		iteratorT;

		if(!s.atEnd()) {
			valueT ch = s.get();

			if(derived().test(ch)) {
				iteratorT	save = s.first;
				s++;

				return s.createMatch(1, ch, save, s.first);
			}
		}
		alias	parserResult!(_thisT, scannerT)._resultT		resultT;
		return conv!(resultT)(s.noMatch());
	}
}

/**\brief base class for parsers which deal with individual characters and supports decoding from utf-8, utf-16
	\note deriving parser must have an alias _charT which specifies the character type it supports */
class decodingCharParser(derivingT) : parser!(derivingT) {
	alias	typeof(this)		_thisT;

	template	result(scannerT) {
		alias	matchResult!(scannerT, derivingT._charT)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	scannerT._valueT		valueT;
		alias	scannerT._iteratorT		iteratorT;

		if(!s.atEnd()) {
			static if(is(derivingT._charT == valueT )) {
				/// deriving parser's character type is same as scanner, so don't decode
				valueT ch = s.get();

				if(derived().test(ch)) {
					iteratorT	save = s.first;
					s++;

					return s.createMatch(1, ch, save, s.first);
				}
			} else {
				/// deriving parser has different character type, which must be of greater size than scanners character type
				derivingT._charT ch = s.decode();

				if(derived().test(ch)) {
					iteratorT	save = s.first;
					s.advanceEncoded();

					return s.createMatch(1, ch, save, s.first);
				}
			}
		}

		alias	parserResult!(_thisT, scannerT)._resultT		resultT;
		return conv!(resultT)(s.noMatch());
	}
}

/**\brief object which negates the match sense of a character parser */
class negatedCharParser(posParserT) : charParser!(negatedCharParser!(posParserT)) {
			this(posParserT p)		{	_p = p; }
	bool	test(T)(T ch) /*const*/	{ return !_p.test(ch); }

private:
	posParserT	_p;
}

/**\brief convenience function to create a negated character parser */
negatedCharParser!(posParserT)
negate(posParserT)(posParserT p) {
	return new negatedCharParser!(posParserT)(p);
}

/**\brief negate a negated character parser */
T
negate(T : negatedCharParser!(T))(T n) {
	return n._p;
}

/**\brief parser to match a single character */
class chLit(charT) : decodingCharParser!(chLit!(charT)){
	alias	charT	_charT;

			this(charT ch) 		{ _ch = ch; }
	bool 	test(charT ch)/*const*/	{ return _ch == ch; }

private:
	charT	_ch;
}

/**\brief convenience function to create a chLit parser */
chLit!(charT)
chP(charT)(charT ch) {
	return new chLit!(charT)(ch);
}

/**\brief parser to match an inclusive character range, ie first <= char <= last */
class chRange(charT) : decodingCharParser!(chRange!(charT)) {
	alias	charT	_charT;

	this(charT first, charT last) {
		assert(first < last, "chRange!(charT).this(charT first, charT last) - first must be less than last");
		_first = first; _last = last;
	}

	bool	test(charT ch)/*const*/ { return _first <= ch && ch <= _last; }
private:
	charT	_first, _last;
}

/**\brief convenience function to create a chRange parser */
chRange!(charT)
chRangeP(charT)(charT first, charT last) {
	return new chRange!(charT)(first, last);
}

/**\brief parser to match a character sequence.
	\details c.f. strLit chSeq can be used at the phrase level, whilst strLit works only
		at the character level. that is characters can be seperated by the skip parser.
		e.g. chSeq("ABCDEFG") can match 'ABCDEFG', 'A B C D E F G', 'AB CD EFG' when used with
		a white space skip parser. */
class chSeq(iteratorT) : parser!(chSeq!(iteratorT)) {
	alias	typeof(this)	_thisT;

	this(iteratorT first, iteratorT last) {
		_first = first;
		_last = last;
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT		resultT;
		return impl1.stringParser!(resultT)(_first, _last, s);
	}

private:
	iteratorT	_first, _last;
}

/**\brief parser to match an exact string.
	\details c.f. chSeq strLit does not allow skipping between characters */
class strLit(iteratorT) : parser!(strLit!(iteratorT)) {
	alias	typeof(this)	_thisT;

	this(iteratorT first, iteratorT last) {
		_seq = new chSeq!(iteratorT)(first, last);
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT		resultT;
		return impl0.contiguousParserParse!(resultT)(_seq, s);
	}

private:
	chSeq!(iteratorT)	_seq;
}

/**\brief match nothing parser */
class nothingParser : parser!(nothingParser) {
	alias	typeof(this)	_thisT;

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		return s.noMatch();
	}
};

	/**\brief convenience global to hold a nothingParser. */
	nothingParser	nothingP;
	anycharParser	negate(parserT : nothingParser)(nothingParser p)		{ return anycharP; }
	static this() { nothingP = new nothingParser; }

/**\brief match any character */
class anycharParser : charParser!(anycharParser) {
	bool test(charT)(charT) { return true; }
}

	/**\brief convenience global to hold a anycharParser. */
	anycharParser	anycharP;
	nothingParser	negate(parserT : anycharParser)(anycharParser p)		{ return nothingP; }
	static this() { anycharP = new anycharParser; }

///\name character class parsers. all use the std.ctype function of the corresponding name
//@{
class alnumParser : charParser!(alnumParser) {
	bool	test(charT)(charT ch) { return 0 != isalnum(ch); }
}

	alnumParser alnumP;
	static this() { alnumP = new alnumParser; }

class alphaParser : charParser!(alphaParser) {
	bool	test(charT)(charT ch) { return 0 != isalpha(ch); }
}

	alphaParser alphaP;
	static this() { alphaP = new alphaParser; }

class cntrlParser : charParser!(cntrlParser) {
	bool	test(charT)(charT ch) { return 0 != iscntrl(ch); }
}

	cntrlParser cntrlP;
	static this() { cntrlP = new cntrlParser; }

class digitParser : charParser!(digitParser) {
	bool	test(charT)(charT ch) { return 0 != isdigit(ch); }
}

	digitParser	digitP;
	static this() { digitP = new digitParser; }

class graphParser : charParser!(graphParser) {
	bool	test(charT)(charT ch) { return 0 != isgraph(ch); }
}

	graphParser	graphP;
	static this() { graphP = new graphParser; }

class lowerParser : charParser!(lowerParser) {
	bool	test(charT)(charT ch) { return 0 != islower(ch); }
}

	lowerParser lowerP;
	static this() { lowerP = new lowerParser; }

class printParser : charParser!(printParser) {
	bool	test(charT)(charT ch) { return 0 != isprint(ch); }
}

	printParser printP;
	static this() { printP = new printParser(); }

class punctParser : charParser!(punctParser) {
	bool	test(charT)(charT ch) { return 0 != ispunct(ch); }
}

	punctParser punctP;
	static this() { punctP = new punctParser; }

class blankParser : charParser!(blankParser) {
	bool	test(charT)(charT ch) { return 0 != isblank(ch); }
}

	blankParser blankP;
	static this() { blankP = new blankParser; }

class spaceParser : charParser!(spaceParser) {
	bool	test(charT)(charT ch) { return 0 != isspace(ch); }
}

	spaceParser spaceP;
	static this() { spaceP = new spaceParser; }

class upperParser : charParser!(upperParser) {
	bool	test(charT)(charT ch) { return 0 != isupper(ch); }
}

	upperParser upperP;
	static this() { upperP = new upperParser; }

class xdigitParser : charParser!(xdigitParser) {
	bool	test(charT)(charT ch) { return 0 != isxdigit(ch); }
}

	xdigitParser xdigitP;
	static this() { xdigitP = new xdigitParser; }
//@}

class eolParser : parser!(eolParser)
{
	alias	typeof(this)	_thisT;

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	scannerT._matchPolicyT._lengthT		lengthT;

		alias	scannerT._valueT		valueT;
		alias	scannerT._iteratorT		iteratorT;

		iteratorT	save = s.first;
		iteratorT	curr = s.first;
		lengthT		len;

		if(!s.atEnd() && *curr == '\r') {
			++curr;
			++len;
		}

		// Don't call skipper here
		if(curr != s.last && *curr == '\n') {
			++curr;
			++len;
		}
		s.first = curr;

		if(len)
			return s.createMatch(len, nilT(), save, s.first);
		return s.noMatch();
	}
}

	eolParser eolP;
	static this() { eolP = new eolParser; }

class endParser : parser!(endParser)
{
	alias	typeof(this)	_thisT;

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT scan) {
		if(scan.atEnd())
			return scan.emptyMatch();
		return scan.noMatch();
	}
}

	endParser endP;
	static this() { endP = new endParser; }
