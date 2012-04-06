/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.parse;

import spiritd.impl.types;

version(D_Version2) {
	public import spiritd.ver.parsev2;
} else {
	public import spiritd.ver.parsev1;
}

struct parseInfo(iteratorT) {
	intptr_t	length()	{ return _length; }

	intptr_t	_length;	///< number of input characters
	iteratorT	_end;		///< iterator to character after last consumed
}
