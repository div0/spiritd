/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.parse;

import spiritd.parse;
import spiritd.primitives;
import spiritd.scanner;
import spiritd.skipper;

/**\brief implementation of phrase parser.
	\details
		phrase parsing uses the supplied skipper to skip space between phrases. the skipper
		parser can be a complex parser in it's own right.
*/
parseInfo!(iteratorT)
parseImpl(charT, iteratorT, grammarT, skipperT)(iteratorT begin, iteratorT end, grammarT grammar, skipperT skipper) {
	alias	skipParserPolicy!(charT, skipperT, defIterationPolicy!(charT))	iterPolT;
	alias	defMatchPolicy					matchPolT;
	alias	defActionPolicy!(iteratorT)		actionPolT;

	alias	scannerPolicies!(iterPolT, matchPolT, actionPolT)	scnrPolT;

	scope iterPol = new iterPolT(skipper);
	scope matchPol = new matchPolT;
	scope actionPol = new actionPolT;
	scope s = new scanner!(iteratorT, scnrPolT)(iterPol, matchPol, actionPol, begin, end);
	scope m = grammar.parse(s);

	parseInfo!(iteratorT)	t = { m.length(), s.first() };
	return t;
}

/**\brief specialisation for when the skipper is spaceP.
	\details
		spaceP is the default skip policy, so in this case the specialisation is to take
		no special action to parse phrases
*/
parseInfo!(iteratorT)
parseImpl(charT, iteratorT, grammarT, skipperT : spaceParser)(iteratorT begin, iteratorT end, grammarT grammar, skipperT skipper) {
	/// use default polices
	alias	defSkipPolicy!(charT)			iterPol;
	alias	defMatchPolicy					matchPol;
	alias	defActionPolicy!(iteratorT)		actionPol;

	alias	scannerPolicies!(iterPol, matchPol, actionPol)	scnrPol;

	scope s = new scanner!(iteratorT, scnrPol)(begin, end);
	scope m = grammar.parse(s);

	parseInfo!(iteratorT)	t = { m.length(), s.first() };
	return t;
}
