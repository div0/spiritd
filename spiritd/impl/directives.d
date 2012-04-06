/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.directives;

import spiritd.match;
import spiritd.scanner;
import spiritd.skipper;
import spiritd.composite.directivesCommon;

/**\brief function to turn off skipping so parsers can work at the character level */
resultT
contiguousParserParse(resultT, parserT, scannerT)(parserT p, scannerT s) {
	alias	noSkipPolicy!(scannerT._valueT, scannerT._iterationPolicyT)	noSkipPoliciesT;
	scope	noskipPol = new noSkipPoliciesT;

	s.skip(s);
	scope	noSkipScanner = s.changeIterPolicies!(noSkipPoliciesT)(s, noskipPol);

	auto	m = p.parse(noSkipScanner);
	if(m.match)
		s.first = noSkipScanner.first;
	return	m;
}

resultT
implicitLexemeParse(resultT, parserT, scannerT)(parserT p, scannerT s) {
	alias	noSkipPolicy!(scannerT._valueT, scannerT._iterationPolicyT)	noSkipPoliciesT;
	scope	noskipPol = new noSkipPoliciesT;

	s.skip(s);
	scope	noSkipScanner = s.changeIterPolicies!(noSkipPoliciesT)(s, noskipPol);

	auto	m = p.parseMain(noSkipScanner);
	if(m.match)
		s.first = noSkipScanner.first;
	return	m;
}

resultT
inhibitCaseParserParse(resultT, parserT, scannerT)(parserT p, scannerT s) {
	alias	inhibitCasePolicy!(scannerT._iterationPolicyT)		inhibCasePoliciesT;
	scope	nocasePol = new inhibCasePoliciesT;

	s.skip(s);
	scope	inhibitCaseScanner = s.changeIterPolicies!(inhibCasePoliciesT)(s, nocasePol);

	auto	m = p.parse(inhibitCaseScanner);
	if(m.match)
		s.first = inhibitCaseScanner.first;
	return	conv(m);
}
