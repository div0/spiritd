/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
		Copyright (c) 2002-2003 Joel de Guzman
		Copyright (c) 2002-2003 Hartmut Kaiser

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.ver.asParserv2;

import spiritd.primitives;

template	asParser(T) {
	alias	T	_type;
	T		convert(T t)	{ return t; }
}

template	asParser(T : char) {
	alias	chLit!(T)	_type;
	_type	convert()(T ch)	{ return new chLit!(T)(ch); }
}

template	asParser(T : wchar) {
	alias	chLit!(T)	_type;
	_type	convert()(T ch)	{ return new chLit!(T)(ch); }
}

template	asParser(T : immutable(char)[]) {
	alias	strLit!(immutable(char)*)	_type;
	_type	convert()(T str)	{ return new strLit!(immutable(char)*)(str.ptr, str.ptr + str.length); }
}
