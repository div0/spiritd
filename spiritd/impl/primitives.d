/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2003 Martin Wille

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.primitives;

import std.stdint;

import spiritd.nil;

resultT stringParser(resultT, iteratorT, scannerT)(iteratorT first, iteratorT last, scannerT s) {
	scannerT._iteratorT		saved = s.first;
	ptrdiff_t				len = last - first;

	while( first != last ) {
		if (s.atEnd() || (*first != s.get())) {
			return s.noMatch();
		}
		++first;
		s++;
	}
	return s.createMatch(len, nilT(), saved, s.first);
}
