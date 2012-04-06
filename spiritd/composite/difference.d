/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.difference;

import spiritd.composite.composite;
import spiritd.match;
import spiritd.parser;
import spiritd.meta.asParser;

/**\brief a - b, match a but not b */
class difference(aT, bT) : binary!(aT, bT, parser!(difference!(aT, bT))) {
	alias	typeof(this)			_thisT;
	alias	differenceGenerator		_generatorT;

	this(aT a, bT b)	{ super(a, b); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		alias	scannerT._iteratorT							iteratorT;

		iteratorT	save = s.first;
		resultT		hl = conv(left.parse(s));

		if(hl.match) {
			iteratorT	endOfLeft = s.first;
			s.first	= save;
			resultT		hr = conv(right.parse(s));

 			if(!hr.match || hr.length < hl.length) {
				s.first = endOfLeft;
				return hl;
			}
		}
		return s.noMatch();
	}
}

template differenceGenerator() {
	template result(aT, bT) {
		alias	difference!(asParser!(aT)._type, asParser!(bT)._type)		_resultT;
	}

	difference!(asParser!(aT)._type, asParser!(bT)._type)
	generate(aT, bT)(aT a, bT b) {
		return new difference!(asParser!(aT)._type, asParser!(bT)._type)(asParser!(aT).convert(a), asParser!(bT).convert(b));
	}
}
