/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2003 Martin Wille

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.parser;

import spiritd.action;
import spiritd.match;
import spiritd.nil;
import spiritd.scanner;
import spiritd.impl.debugging;

/**\brief types used to distinguish different types of parsers for refactoring purposes */
class plainParserCategory {}
class needsRefactingParserCategory {}
class binaryParserCategory : needsRefactingParserCategory {}
class unaryParserCategory : needsRefactingParserCategory {}
class actionParserCategory : unaryParserCategory {}

/**\brief meta function to determine the return type of a parsers parse method.
	\details this is a default function which simply forwards determination of the parser result
		type back to the parser. specailisations can be created in order to override the parser
		result if required.
	\tparam parserT type of the parser
	\tparam scannerT type of the scanner the parse is being used with */
template parserResult(parserT, scannerT) {
	alias	parserT.result!(scannerT)._resultT		_resultT;
}

/**\brief base meta class for parsers.
	\details provides some convenience functions and specifies a default return type of the parse method. */
class parser(derivingT) {
	alias	derivingT				_derivedT;
	alias	plainParserCategory		_categoryT;

	template	result(scannerT) {
		alias	matchResult!(scannerT, nilT)._resultT	_resultT;
	}
final:
	derivingT derived() {	// cast through void* to prevent dynamic cast which returns 0
		return cast(derivingT)(cast(void*)this);
	}

	action!(derivingT, actionT)
	opIndex(actionT)(actionT actor)	{
		auto t = derived();
		return new action!(derivingT, actionT)(t, actor);
	}

}
