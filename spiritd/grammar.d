/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 2001-2003 Joel de Guzman
			Copyright (c) 2002-2003 Martin Wille
			Copyright (c) 2003 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.grammar;

import spiritd.parser;

class grammar(derivingT) : parser!(grammar!(derivingT)) {
	alias	typeof(this)	_thisT;

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	derivingT.definition!(scannerT)		grammarDef;
		scope	def = new grammarDef;
		scope	start = def.start(cast(derivingT)(cast(void*)this));
		return start.parse(s);
	}

}
