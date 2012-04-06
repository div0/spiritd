/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.sequenceOr;

import spiritd.composite.composite;
import spiritd.match;
import spiritd.parser;

/**\brief sequence parser, handles a || b
	\details
		Handles expressions of the form:

			a || b

		Equivalent to

			a | b | a >> b;

		where a and b are parsers. The expression returns a composite
		parser that matches matches a or b in sequence.
 */
class sequenceOr(aT, bT) : binary!(aT, bT, parser!(sequenceOr!(aT, bT))) {
	alias	typeof(this)		_thisT;
	alias	sequenceOrGenerator	_generatorT;

	this(aT a, bT b)	{ super(a, b); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;

		s._iteratorT	save = s.first;
		resultT			matchLeft = conv(left.parse(s));

		if(matchLeft.match) {
			resultT		matchRight;

			save = s.first;
			matchRight = conv(right.parse(s));

			if(matchRight.match) {
				s.concatMatch(matchLeft, matchRight);
				return matchLeft;
			}
			s.first = save;
			return matchLeft;
		}
		s.first = save;
		return conv(right.parse(s));
	}
}

template sequenceOrGenerator() {
	template result(aT, bT) {
		alias	sequenceOr!(asParser!(aT)._type, asParser!(bT)._type)		_resultT;
	}

	sequenceOr!(asParser!(aT)._type, asParser!(bT)._type)
	generate(aT, bT)(aT a, bT b) {
		return new sequenceOr!(asParser!(aT)._type, asParser!(bT)._type)(asParser!(aT).convert(a), asParser!(bT).convert(b));
	}
}
