/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.optional;

import spiritd.composite.composite;
import spiritd.match;
import spiritd.parser;

/**\brief handles opt(a), match 0 or 1 times */
class optional(sub) : unary!(sub, parser!(optional!(sub) ) ) {
	alias	typeof(this)		_thisT;
	alias	optionalGenerator	_generatorT;

	this(sub s) { super(s); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		alias	scannerT._iteratorT							iteratorT;

		iteratorT	save = s.first;
		resultT		r = conv(subject.parse(s));

		if(r.match)
			return r;

		s.first = save;
		return s.emptyMatch();
	}
}

template optionalGenerator() {
	template result(aT) {
		alias	optional!(aT)		_resultT;
	}

	optional!(aT)
	generate(aT)(aT a) {
		return new optional!(aT)(a.derived());
	}
}
