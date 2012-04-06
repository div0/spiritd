/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.ver.parsev1;

import spiritd.parse;
import spiritd.parser;
import spiritd.impl.parse;

/**\brief convenience function to parse a string.
	\details
		this function shows how to create the neccessary scanner object
		which mediates access to input. it is the main entry point for parsing in
		memory strings and should be used as the basis of for any clients which need
		to provide more specialised control of the data source
	\remarks
		follow the code throught to spiritd.impl.parse for the implementation details
*/
parseInfo!(char*)
parse(grammarT, skipperT)(string input, grammarT grammar, skipperT skipper) {
	return parseImpl!(char)(input.ptr, input.ptr + input.length, grammar, skipper);
}

parseInfo!(char*)
parse(grammarT, skipperT)(char* pBegin, char* pEnd, grammarT grammar, skipperT skipper) {
	return parseImpl!(char)(pBegin, pEnd, grammar, skipper);
}

parseInfo!(wchar*)
parse(grammarT, skipperT)(wstring input, grammarT grammar, skipperT skipper) {
	return parseImpl!(wchar)(input.ptr, input.ptr + input.length, grammar, skipper);
}

parseInfo!(wchar*)
parse(grammarT, skipperT)(wchar* pBegin, wchar* pEnd, grammarT grammar, skipperT skipper) {
	return parseImpl!(wchar)(pBegin, pEnd, grammar, skipper);
}
