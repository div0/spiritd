/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.rule;

import impl = spiritd.impl.rule;

final class rule(scannerT) : impl.rule!(rule!(scannerT), scannerT) {
	alias	typeof(this)								_thisT;
	alias	result!(scannerT)._resultT._valueT			_attrT;
	alias	impl.abstractParser!(scannerT, _attrT)		_abstractParserT;

	_thisT
	opAssign(parserT)(parserT p) {
		_p = new impl.concreteParser!(parserT, scannerT, _attrT)(p);
		return this;
	}

	static _thisT
	create(parserT)(parserT p) {
		_thisT	t = new _thisT;
		t = p;
		return t;
	}

	_abstractParserT	get()	{ return _p; }

private:
	_abstractParserT	_p;
}
