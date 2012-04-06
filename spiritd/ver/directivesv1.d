/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2001 Daniel Nuffer

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.ver.directivesv1;

import spiritd.parser;
import spiritd.primitives;
import spiritd.composite.composite;
import spiritd.composite.directivesCommon;
import spiritd.impl.directives;

template inhibitCaseGenerator() {
	static inhibitCase!(strLit!(char*))
	generate(T : char*)(T str) {
		return new inhibitCase!(strLit!(char*))(new strLit!(char*)(str));
	}

	static inhibitCase!(strLit!(wchar*))
	generate(T : wchar*)(T str) {
		return new inhibitCase!(strLit!(wchar*))(str);
	}

	static inhibitCase!(chLit!(char))
	generate(T : char)(T ch) {
		return new inhibitCase!(chLit!(char))(ch);
	}

	static inhibitCase!(chLit!(wchar))
	generate(T : wchar)(T ch) {
		return new inhibitCase!(chLit!(wchar))(ch);
	}

	static inhibitCase!(parserT)
	generate(parserT)(parser!(parserT) subject) {
		return new inhibitCase!(parserT)(subject.derived());
	}

	inhibitCase!(strLit!(char*))
	opIndex(T : char*)(T str) {
		return new inhibitCase!(strLit!(char*))(str);
	}

	inhibitCase!(strLit!(wchar*))
	opIndex(T : wchar*)(T str) {
		return new inhibitCase!(strLit!(wchar*))(str);
	}

	inhibitCase!(chLit!(char))
	opIndex(T : char)(T ch) {
		return new inhibitCase!(chLit!(char))(new chLit!(char)(ch));
	}

	inhibitCase!(chLit!(wchar))
	opIndex(T : wchar)(T ch) {
		return new inhibitCase!(chLit!(wchar))(new chLit!(wchar)(ch));
	}

	inhibitCase!(parserT)
	opIndex(parserT)(parser!(parserT) subject) {
		return new inhibitCase!(parserT)(subject.derived());
	}
}

struct sAsLowerD {
	mixin	inhibitCaseGenerator!();
}

	sAsLowerD	asLowerD;
