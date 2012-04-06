/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.action;

import spiritd.nil;
import spiritd.parser;
import spiritd.scanner;
import spiritd.composite.composite;
import spiritd.impl.debugging;

/**\brief the action parser binds a parser to a semantic action, ie a function in the client application.
	\details really the action parser is a composite and logically belongs in composite/ which is where
		it is in boost::spirit, but it's also the principle means by which a client application interfaces
		with the parser library, so I think it is important enough to be at the top level. */
class action(parserT, actionT) : unary!(parserT, parser!(action!(parserT, actionT))) {
	alias	typeof(this)			_thisT;
	alias	actionParserCategory	_categoryT;
	alias	actionT					_predicateT;

	template	result(scannerT) {
		alias	parserResult!(parserT, scannerT)._resultT	_resultT;
	}

	this(parserT p, actionT a) { super(p); _a = a; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;

		s.atEnd();	// do skip if needed
		s._iteratorT	save = s.first;
		auto			h = subject.parse(s);

		if(h.match)
			s.invokeAction(_a, h.value, save, s.first);
		return h;
	}

	_predicateT	predicate() { return _a; }

private:
	actionT	_a;
}
