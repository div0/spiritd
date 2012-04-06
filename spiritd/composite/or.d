/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.or;

import spiritd.match;
import spiritd.parser;
import spiritd.composite.composite;
import spiritd.meta.asParser;

/**\brief or parser, handles a | b \note in spirit it's called alternative */
class or(aT, bT) : binary!(aT, bT, parser!(or!(aT, bT))) {
	alias	typeof(this)	_thisT;
	alias	orGenerator		_generatorT;

	this(aT a, bT b)	{ super(a, b); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		alias	scannerT._iteratorT							iteratorT;

		iteratorT	save = s.first;
		resultT		hit = conv(left.parse(s));

		if(hit.match())
			return hit;

		s.first = save;
		return conv(right.parse(s));
	}
}

template orGenerator() {
	template result(aT, bT) {
		alias	or!(asParser!(aT)._type, asParser!(bT)._type)		_resultT;
	}

	or!(asParser!(aT)._type, asParser!(bT)._type)
	generate(aT, bT)(aT a, bT b) {
		return new or!(asParser!(aT)._type, asParser!(bT)._type)(asParser!(aT).convert(a), asParser!(bT).convert(b));
	}
}
