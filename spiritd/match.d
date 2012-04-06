/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.match;

import std.stdint;
import std.stdio;

import spiritd.nil;

struct Match(T) {
	alias	std.stdint.intptr_t		ptrdiff_t;
	alias	typeof(this)			_thisT;
	alias	T						_valueT;

	static Match!(T)	opCall(in ptrdiff_t len) {
		Match!(T)	t = { T.init, len };
		return t;
	}

	static Match!(T)	opCall(in ptrdiff_t len, T val) {
		Match!(T) t = { val, len };
		return t;
	}

	void concat(matchT)(in matchT other) {
		assert(match() && other.match());
		_len += other._len;
	}

	bool		match()		{ return _len >= 0; }
	ptrdiff_t	length()	{ return _len; }
	T			value()		{ return _val; }
	void		value(T v)	{ _val = v; }

private:
	T			_val;
	ptrdiff_t	_len;
}

struct Match(T : nilT) {
	alias	typeof(this)	_thisT;
	alias	nilT			_valueT;

	static Match!(nilT)	opCall(in ptrdiff_t len) {
		Match!(nilT)	t = { len };
		return t;
	}

	void concat(matchT)(matchT other) {
		assert(_len >= 0 && other._len >= 0);
		_len += other._len;
	}

	bool		match()		{ return _len >= 0; }
	ptrdiff_t	length()	{ return _len; }
	T			value()		{ return nilT(); }
private:
	ptrdiff_t	_len;
}

/**\brief convenience funcs to convert between various match types.
	these are neccesary due to Ds lack of template constructors */
Match!(nilT)	conv(T)(in Match!(T) arg)		{ return Match!(nilT)(arg._len); }
T				conv(T)(in Match!(nilT) arg)	{ return T(arg._len); }
