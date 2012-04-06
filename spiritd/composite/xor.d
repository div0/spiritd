/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.xor;

import spiritd.match;
import spiritd.parser;
import spiritd.composite.composite;
import spiritd.meta.asParser;

/**\brief xor parser, handles a ^ b */
class xor(aT, bT) : binary!(aT, bT, parser!(xor!(aT, bT))) {
	alias	typeof(this)	_thisT;
	alias	xorGenerator	_generatorT;

	this(aT a, bT b)	{ super(a, b); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		alias	scannerT._iteratorT							iteratorT;

		iteratorT	start = s.first, endLeft;
		resultT		hl = conv(left.parse(s));
		endLeft = s.first;
		s.first = start;
		resultT		hr = conv(right.parse(s));

		if(hl.match ? !hr.match : hr.match) {
			if(hl.match)
				s.first = endLeft;
			return hl.match ? hl : hr;
		}
		return s.noMatch();
	}
}

template xorGenerator() {
	template result(aT, bT) {
		alias	xor!(asParser!(aT)._type, asParser!(bT)._type)		_resultT;
	}

	xor!(asParser!(aT)._type, asParser!(bT)._type)
	generate(aT, bT)(aT a, bT b) {
		return new xor!(asParser!(aT)._type, asParser!(bT)._type)(asParser!(aT).convert(a), asParser!(bT).convert(b));
	}
}
