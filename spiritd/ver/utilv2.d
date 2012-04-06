/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.ver.utilv2;

import spiritd.primitives;
import spiritd.scanner;
import spiritd.skipper;

/**\brief convenience function to create chSeq parser */
chSeq!(immutable(charT)*)
chSeqP(charT)(immutable(charT[]) str) {
	return new chSeq!(immutable(charT)*)(str.ptr, str.ptr + str.length);
}

/**\brief convenience function to create strLit parser */
strLit!(immutable(charT)*)
strLitP(charT)(immutable(charT[]) str) {
	return new strLit!(immutable(charT)*)(str.ptr, str.ptr + str.length);
}

scanner!(immutable(char)*, scannerPolicies!(defSkipPolicy!(char), defMatchPolicy, defActionPolicy!(immutable(char)*)))
makeScanner(string str) {
	return new scanner!(immutable(char)*, scannerPolicies!(defSkipPolicy!(char), defMatchPolicy, defActionPolicy!(immutable(char)*)))(str.ptr, str.ptr + str.length);
}

template scannerType(T : string){
	alias	scanner!(immutable(char)*, scannerPolicies!(defSkipPolicy!(char), defMatchPolicy, defActionPolicy!(immutable(char)*)))	sT;
}

template scannerType(T : wstring){
	alias	scanner!(immutable(wchar)*, scannerPolicies!(defSkipPolicy!(wchar), defMatchPolicy, defActionPolicy!(immutable(char)*)))	sT;
}

template iteratorType(T : string) {
	alias immutable(char)*	_resultT;
}

template iteratorType(T : wstring) {
	alias immutable(wchar)*	_resultT;
}
