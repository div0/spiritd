/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.ctype;

import a = std.ascii;
import std.uni;

// mapped some of the more general ones to the unicode versions which
// will return true for a lot more characters than the ascii versions.
//
// good idea/bad idea?

alias a.isAlphaNum isalnum;
alias isAlpha isalpha;
alias isControl iscntrl;
alias isNumber isdigit;
alias isGraphical isgraph;
alias isLower islower;
alias a.isPrintable isprint;
alias isPunctuation ispunct;
alias isWhite isspace;
alias isUpper isupper;
alias a.isHexDigit isxdigit;
alias toLower tolower;

/**\brief true if character is a space or tab */ 
bool isblank(dchar ch) {
	return ch == ' ' || ch == '\t';
}
