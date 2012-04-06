/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.intersection;

import spiritd.composite.composite;
import spiritd.match;
import spiritd.parser;

/**\brief handles a & b, i.e. match a and b */
class intersection(aT, bT) : binary!(aT, bT, parser!(intersection!(aT, bT) ) ) {
	alias	typeof(this)			_thisT;
	alias	intersectionGenerator	_generatorT;

	this(aT a, bT b)	{ super(a, b); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		alias	scannerT._iteratorT							iteratorT;

		iteratorT	save = s.first;
		resultT		hitLeft = conv(left.parse(s));

		if(hitLeft.match) {
			scope auto	bscan = new scannerT(save, s.first);
			resultT		hitRight = conv(right.parse(bscan));

			if(hitLeft.length == hitRight.length)
				return hitLeft;
		}
		return s.noMatch();
	}
}

template intersectionGenerator() {
	template result(aT, bT) {
		alias	intersection!(asParser!(aT)._type, asParser!(bT)._type)		_resultT;
	}

	intersection!(asParser!(aT)._type, asParser!(bT)._type)
	generate(aT, bT)(aT a, bT b) {
		return new intersection!(asParser!(aT)._type, asParser!(bT)._type)(asParser!(aT).convert(a), asParser!(bT).convert(b));
	}
}
