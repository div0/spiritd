/*=============================================================================
	spiritd - Copyright (c) 2010 s.d.hammett
		a D2 parser library ported from boost::spirit

	Parsers useful for xml processing.
	\see http://www.w3.org/TR/2008/REC-xml-20081126/

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.parsers.xml;

import spiritd.primitives;
import spiritd.impl.debugging;

/**\brief parser to match white space. */
class whiteSpace : charParser!(whiteSpace){
	bool 	test(dchar ch) {
		bool rv = ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r';
		return rv;
	}
}
