/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer
			Copyright (c) 2002 Hartmut Kaiser

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.list;

import spiritd.composite.kleeneStar;
import spiritd.composite.sequence;

/**\brief create a list, i.e. one of more 'a's seperated by 'b's \note a must != b  */
sequence!(aT, kleeneStar!(sequence!(bT, aT)))
list(aT, bT)(aT a, bT b) {
	return new
		sequence!(aT, kleeneStar!(sequence!(bT, aT)))(
			a,
			new kleeneStar!(sequence!(bT, aT))(
				new sequence!(bT, aT)(b, a)
			)
		);
}
