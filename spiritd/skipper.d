/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.skipper;

import spiritd.scanner;
import spiritd.impl.ctype;
import spiritd.impl.parse;
import spiritd.impl.skipper;

/**\brief the default skip policy. skips characters for which std.ctype.isspace returns true.
	\tparam character type which is mutable and compatible with the character type returned by the scanner
	\tparam iteratorPolicyT policy which provides actual iteration manipulation funcs */
class defSkipPolicy(charT, iteratorPolicyT = defIterationPolicy!(charT)) : iteratorPolicyT {
	alias	iteratorPolicyT		_superT;

	static void advance(scannerT)(scannerT s) {
		_superT.advance(s);
		s.skip(s);
	}

	static void advanceEncoded(scannerT)(scannerT s) {
		_superT.advanceEncoded(s);
		s.skip(s);
	}

	static bool atEnd(scannerT)(scannerT s) {
		s.skip(s);
		return _superT.atEnd(s);
	}

	static void skip(scannerT)(scannerT s) {
		while (!_superT.atEnd(s) && isspace(_superT.get(s)))
			_superT.advance(s);
	}
}

/**\brief skip policy which performs no skipping. used when matching at the character level (eg by lexemD directives and strLit).
	\tparam character type which is mutable and compatible with the character type returned by the scanner
	\tparam iteratorPolicyT policy which provides actual iteration manipulation funcs */
class noSkipPolicy(charT, iteratorPolicyT = defIterationPolicy!(charT)) : iteratorPolicyT {
	alias	iteratorPolicyT		superT;

	static void skip(scannerT)(scannerT scan) {}
};

/**\brief skip policy which uses a lexemD parser to skip characters between phrases. this allows skipping of comments.
	\tparam parserT type of the skip parser
	\tparam baseT base iteration policy that this inherits from to gain default iteration behaviour
 */
class skipParserPolicy(charT, parserT, baseT) : defSkipPolicy!(charT, baseT) {

	this() {}

	this(parserT skipParser) { _subject = skipParser; }

	void skip(scannerT)(scannerT s) {
		skipperSkip(_subject, s);
	}

	parserT skipper()	{ return _subject; }

private:
	parserT	_subject;
};
