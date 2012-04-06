/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.sequence;

import spiritd.composite.composite;
import spiritd.match;
import spiritd.parser;

/**\brief sequence parser, handles a >> b */
class sequence(aT, bT) : binary!(aT, bT, parser!(sequence!(aT, bT))) {
	alias	typeof(this)		_thisT;
	alias	sequenceGenerator	_generatorT;

	this(aT a, bT b)	{ super(a, b); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		resultT	matchA = conv(left.parse(s));
		if(matchA.match()) {
			resultT	matchB = conv(right.parse(s));
			if(matchB.match()) {
				s.concatMatch(matchA, matchB);
				return matchA;
			}
		}
		return s.noMatch();
	}
}

template sequenceGenerator() {
	template result(aT, bT) {
		alias	sequence!(asParser!(aT)._type, asParser!(bT)._type)		_resultT;
	}

	sequence!(asParser!(aT)._type, asParser!(bT)._type)
	generate(aT, bT)(aT a, bT b) {
		return new sequence!(asParser!(aT)._type, asParser!(bT)._type)(asParser!(aT).convert(a), asParser!(bT).convert(b));
	}
}
