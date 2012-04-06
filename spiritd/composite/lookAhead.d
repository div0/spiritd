/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.lookAhead;

import spiritd.parser;
import spiritd.match;
import spiritd.nil;
import spiritd.noAction;
import spiritd.impl.debugging;

/**\brief parser which looks ahead into the input data to chose which parser to apply
	\details
		The look ahead parser first runs the two contained parsers with symantic actions disabled,
		then calls a user supplied function which choses which of the parsers should be used.
		The correct parser is then run as normal. This simplies the use of symantic actions;
		there is no need to deal with the side effects of symantic actions which would normally
		get called by the incorrect parser. */
class lookAhead(aT, bT, selectorT) : parser!(lookAhead!(aT, bT, selectorT)) {
	alias	typeof(this)			_thisT;

	this(aT a, bT b, selectorT s)	{ _a = a; _b = b; _s = s; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	noActionPolicy!(scannerT._iteratorT)		noActionPoliciesT;
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		alias	scannerT._iteratorT		iteratorT;

		scope		noactionPol = new noActionPoliciesT;
		scope		noactionScanner = s.changeActionPolicies!(noActionPoliciesT)(s, noactionPol);
		iteratorT	save = noactionScanner.first;

		resultT[2]	matches;

		matches[0] = _a.parse(noactionScanner);
		noactionScanner.first = save;
		matches[1] = _b.parse(noactionScanner);
		noactionScanner.first = save;

		uint selected = _s(matches);

		if(selected < matches.length)
			switch(selected) {
			case 0:
				return conv(_a.parse(s));
			case 1:
				return conv(_b.parse(s));
			default:
				break;
			}

		return s.noMatch();
	}

private:
	aT	_a;
	bT	_b;
	selectorT	_s;
}
