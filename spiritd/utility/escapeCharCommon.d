/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 2001-2003 Daniel Nuffer

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.utility.escapeCharCommon;

import spiritd.match;
import spiritd.parser;
import spiritd.scanner;
import spiritd.composite.composite;
import spiritd.impl.escapeChar;

class escapeCharAction(parserT, actionT, int flags, charT) : unary!(parserT, parser!(escapeCharAction!(parserT, actionT, flags, charT))) {
	alias	typeof(this)			_thisT;
	alias	actionParserCategory	_categoryT;

	template	result(scannerT) {
		alias matchResult!(scannerT, charT)._resultT	_resultT;
	};

	this(parserT p, actionT a) { super(p); _actor = a; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		return escapeCharActionParse!(flags, charT).parse(s, this);
	}

	actionT	predicate()	{ return _actor; }

private:
	actionT _actor;
}

class escapeCharParser(int flags, charT) : parser!(escapeCharParser!(flags, charT)) {
	static assert(EscapeFlags.cEscapes == flags || EscapeFlags.lexEscapes == flags);

	alias	typeof(this)	_thisT;
//	alias	escapeCharActionParserGen!(flags, charT)	actionParserGeneratorT;

	template	result(scannerT) {
		alias	matchResult!(scannerT, scannerT._valueT)._resultT	_resultT;
	}

	escapeCharAction!(_thisT, actionT, flags, charT)
	opIndex(actionT)(actionT actor) {
		return new escapeCharAction!(_thisT, actionT, flags, charT)(this, actor);
	}

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		scope p = new escapeCharParse!(charT);
		return p.parse!(_thisT)(s);
	}
}

	escapeCharParser!(EscapeFlags.cEscapes, char)	cEscapeCharP;
	escapeCharParser!(EscapeFlags.cEscapes, wchar)	cEscapeWCharP;

	static this() {
		cEscapeCharP = new escapeCharParser!(EscapeFlags.cEscapes, char);
		cEscapeWCharP = new escapeCharParser!(EscapeFlags.cEscapes, wchar);
	}
