/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.rule;

import spiritd.match;
import spiritd.parser;
import spiritd.scanner;

class abstractParser(scannerT, attrT) {
	abstract
	matchResult!(scannerT, attrT)._resultT
	virtualParse(scannerT s);
}

class concreteParser(parserT, scannerT, attrT) : abstractParser!(scannerT, attrT) {
	this(parserT p) { _p = p; }

	override
	matchResult!(scannerT, attrT)._resultT
	virtualParse(scannerT s) {
		return conv(_p.parse(s));
	}
private:
	parserT	_p;
}

class rule(derivingT, scannerT) : parser!(derivingT) {
final:
	parserResult!(derivingT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(derivingT, scannerT)._resultT		resultT;
		alias	derivingT._abstractParserT	pT;

		pT	p = derived().get();

		if( p is null )
			return s.noMatch();

		s._iteratorT	save = s.first;
		resultT			match = p.virtualParse(s);
//		s.groupMatch(match, nilT(), save, s.first);
		return match;
	}
}
