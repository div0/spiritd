/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 2001-2003 Daniel Nuffer

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.utility.escapeChar;

version(D_Version2) {
	public import spiritd.ver.escapeCharv2;
} else {
	public import spiritd.ver.escapeCharv1;
}

public import spiritd.utility.escapeCharCommon;
