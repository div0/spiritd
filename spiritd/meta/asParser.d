/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
		Copyright (c) 2002-2003 Joel de Guzman
		Copyright (c) 2002-2003 Hartmut Kaiser

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.meta.asParser;

import spiritd.primitives;

version(D_Version2) {
	public import spiritd.ver.asParserv2;
} else {
	public import spiritd.ver.asParserv1;
}
