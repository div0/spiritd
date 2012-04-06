/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.directives;

version(D_Version2) {
	public import spiritd.ver.directivesv2;
} else {
	public import spiritd.ver.directivesv1;
}

public import spiritd.composite.directivesCommon;
