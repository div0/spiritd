/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.ver.utilv1;

import spiritd.primitives;
import spiritd.scanner;
import spiritd.skipper;

/**\brief convenience function to create chSeq parser */
chSeq!(charT*)
chSeqP(charT)(charT[] str) {
	return new chSeq!(charT*)(str.ptr, str.ptr + str.length);
}

/**\brief convenience function to create strLit parser */
strLit!(charT*)
strLitP(charT)(charT[] str) {
	return new strLit!(charT*)(str.ptr, str.ptr + str.length);
}

scanner!(char*, scannerPolicies!(defSkipPolicy!(char), defMatchPolicy, defActionPolicy!(char*)))
makeScanner(string str) {
	return new scanner!(char*, scannerPolicies!(defSkipPolicy!(char), defMatchPolicy, defActionPolicy!(char*)))(str.ptr, str.ptr + str.length);
}

template scannerType(T : string){
	alias	scanner!(char*, scannerPolicies!(defSkipPolicy!(char), defMatchPolicy, defActionPolicy!(char*)))	sT;
}

template scannerType(T : wstring){
	alias	scanner!(wchar*, scannerPolicies!(defSkipPolicy!(wchar), defMatchPolicy, defActionPolicy!(char*)))	sT;
}

template iteratorType(T : string) {
	alias char*	_resultT;
}

template iteratorType(T : wstring) {
	alias wchar*	_resultT;
}
