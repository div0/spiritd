/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.composite;

import spiritd.parser;

class unary(sub, baseT) : baseT {
	alias	unaryParserCategory		_categoryT;
	alias	sub						_subjectT;

	this(sub s)	{ _s = s; }

	sub	subject()	{ return _s;}
private:
	sub	_s;
}

class binary(aT, bT, baseT) : baseT {
	alias	binaryParserCategory	_categoryT;
	alias	aT	_leftT;
	alias	bT	_rightT;

	this(aT a, bT b)	{ _a = a; _b = b;}

	aT	left()			{ return _a; }
	bT	right()			{ return _b; }

private:
	aT	_a;
	bT	_b;
}
