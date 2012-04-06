/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.kleeneStar;

import spiritd.composite.composite;
import spiritd.match;
import spiritd.parser;

/**\brief handles *a, i.e. match 0 or more times */
class kleeneStar(sub) : unary!(sub, parser!(kleeneStar!(sub))) {
	alias	typeof(this)			_thisT;
	alias	kleeneStarGenerator		_generatorT;

	this(sub s)	{ super(s); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		alias	scannerT._iteratorT		iteratorT;
		resultT	hit = s.emptyMatch();

		while(true) {
			iteratorT	save = s.first;
			resultT		next = conv(subject.parse(s));

			if(next.match)
				s.concatMatch(hit, next);
			else {
				s.first = save;
				return hit;
			}

		}
		assert(false);
	}
}

template kleeneStarGenerator() {
	template result(aT) {
		alias	kleeneStar!(aT)		_resultT;
	}

	kleeneStar!(aT)
	generate(aT)(aT a) {
		return new kleeneStar!(aT)(a.derived());
	}
}
