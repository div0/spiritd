/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.skipper;

import spiritd.skipper;
import spiritd.impl.debugging;

void skipperSkip(scannerT, skipperT)(skipperT skip, scannerT s) {
	alias	noSkipPolicy!(scannerT._valueT, scannerT._iterationPolicyT)	noSkipPoliciesT;
	scope	noskipPol = new noSkipPoliciesT;
	scope	noSkipScanner = s.changeIterPolicies!(noSkipPoliciesT)(s, noskipPol);

	while(true) {
		s._iteratorT	save = s.first;
		scope 			m = skip.parse(noSkipScanner);

		if(!m.match)
			return;

		s.first = noSkipScanner.first;
	}
}
