/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost.spirit
			Copyright (c) 2002-2003 Hartmut Kaiser

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.refactoring;

import spiritd.parser;
import spiritd.composite.composite;

struct nonNestedRefactoring { alias nonNestedRefactoring embed_t; }
struct selfNestedRefactoring { alias selfNestedRefactoring embed_t; }

//	refactor the left unary operand of a binary parser
//		The refactoring should be done only if the left operand is an
//		unaryParserCategory parser.

template refactorUnaryNested(categoryT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, nestedT, scannerT, binaryT)(parserT, scannerT s, binaryT binary, nestedT /*nestedD*/) {
		return binary.parse(s);
	}
}

template refactorUnaryNested(categoryT : unaryParserCategory) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT, nestedT)(parserT, scannerT s, binaryT binary, nestedT nestedD) {
		alias	binaryT._generatorT				opT;
		alias	binaryT._leftT._generatorT		unaryT;

		scope	p	= unaryT.generate(nestedD[opT.generate(binary.left().subject(), binary.right())]);
		return parse(s);
	}
}

template refactorUnaryNonNested(categoryT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT, scannerT scan, binaryT binary) {
		return binary.parse(scan);
	}
}

template refactorUnaryNonNested(categoryT : unaryParserCategory) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT, scannerT s, binaryT binary) {
		alias	binaryT._generatorT 			opT;
		alias	binaryT._leftT._generatorT		unaryT;

		scope	p = unaryT!().generate(opT!().generate(binary.left().subject(), binary.right()));
		return p.parse(s);
	}
}

template refactorUnaryType(nestedT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT p, scannerT s, binaryT binary, nestedT nested_d) {
		alias	binaryT._leftT._categoryT	categoryT;

		return	refactorUnaryNested!(categoryT).parse(p, s, binary, nested_d);
	}
}

template refactorUnaryType(categoryT : nonNestedRefactoring) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT p, scannerT s, binaryT binary, nonNestedRefactoring) {
		alias	binaryT._leftT._categoryT	categoryT;
		return	refactorUnaryNonNested!(categoryT).parse(p, s, binary);
	}

}

template refactorUnaryType(categoryT : selfNestedRefactoring) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT p, scannerT s, binaryT binary, selfNestedRefactoring nestedTag) {
		alias	binaryT._leftT._categoryT	categoryT;
		alias	parserT._generatorT			generatorT;

		generatorT	nestedD = nestedTag;
		return	refactorUnaryNested!(categoryT).parse(p, s, binary, nestedD);
	}

}

//  refactor the action on the left operand of a binary parser
//
//      The refactoring should be done only if the left operand is an
//      actionParserCategory parser.

template refactorActionNested(categoryT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT, nestedT)(parserT, scannerT s, binaryT binary, nestedT nestedD) {
		return nestedD[binary].parse(s);
	}
}

template refactorActionNested(categoryT : actionParserCategory) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT, nestedT)(parserT, scannerT s, binaryT binary, nestedT nestedD) {
		alias	binaryT._generatorT		genT;
		scope	p =
			nestedD[genT!().generate(binary.left().subject(), binary.right())]
				[binary.left().predicate()];
		return p.parse(s);
	}
}

template refactorActionNonNested(categoryT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT, scannerT s, binaryT binary) {
		return	binary.parse(s);
	}
}

template refactorActionNonNested(categoryT : actionParserCategory) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT, scannerT s, binaryT binary) {
		alias	binaryT._generatorT	genT;

		scope	p = 
			genT!().generate(
				binary.left().subject(),
				binary.right()
			)[binary.left().predicate()];
		return p.parse(s);
	}
}

template refactorActionType(nestedT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT p, scannerT s, binaryT binary, nestedT nestedD) {
		alias	binaryT._leftT._categoryT	categoryT;
		return refactorActionNested!(categoryT).parse(p, s, binary, nestedD);
	}
}

template refactorActionType(categoryT : nonNestedRefactoring) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT p, scannerT s, binaryT binary, nonNestedRefactoring) {
		alias	binaryT._leftT._categoryT	categoryT;
		return refactorActionNonNested!(categoryT).parse(p, s, binary);
	}
}

template refactorActionType(categoryT : selfNestedRefactoring) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, binaryT)(parserT p, scannerT s, binaryT binary, selfNestedRefactoring nestedTag) {
		alias	parserT._generatorT			generatorT;
		alias	binaryT._leftT._categoryT	categoryT;

		generatorT	nestedD(nestedTag);
		return refactorActionNested!(categoryT).parse(p, s, binary, nestedD);
	}
}

//  refactor the action attached to a binary parser
//
//      The refactoring should be done only if the given parser is an
//      binaryParserCategory parser.

template attachActionNested(categoryT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, actionT, nestedT)(parserT, scannerT s, actionT action, nestedT nestedD) {
		return action.parse(s);
	}
}

template attachActionNested(categoryT : binaryParserCategory) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, actionT, nestedT)(parserT, scannerT s, actionT action, nestedT nestedD) {
		alias	actionT._subjectT._generatorT	genT;
		scope	p =
			genT!().generate(
				nested_d[action.subject().left()[action.predicate()]],
				nested_d[action.subject().right()[action.predicate()]]
			);
		return p.parse(s);
	}
}

template attachActionNonNested(categoryT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, actionT)(parserT, scannerT s, actionT action) {
		return action.parse(s);
	}
}

template attachActionNonNested(categoryT : binaryParserCategory) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, actionT)(parserT, scannerT s, actionT action) {
		alias	actionT._subjectT._generatorT	genT;
		scope	p = 
			genT!().generate(
				action.subject().left()[action.predicate()],
				action.subject().right()[action.predicate()]
			);
		return p.parse(s);
	}
}

template attachActionType(nestedT) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, actionT)(parserT p, scannerT s, actionT action, nestedT nestedD) {
		alias	actionT._subjectT._categoryT	categoryT;
		return attachActionNested!(categoryT).parse(p, s, action, nestedD);
	}
}

template attachActionType(categoryT : nonNestedRefactoring) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, actionT)(parserT p, scannerT s, actionT action, nonNestedRefactoring) {
		alias	actionT._subjectT._categoryT	categoryT;
		return attachActionNonNested!(categoryT).parse(p, s, action);
	}
}

template attachActionType(categoryT : selfNestedRefactoring) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT, actionT)(parserT p, scannerT s, actionT action, selfNestedRefactoring nestedTag) {
		alias	parserT._generatorT 			generatorT;
		alias	actionT._subjectT._categoryT	categoryT;

		generatorT	nestedD(nestedTag);
		return	attachActionNested!(categoryT).parse(p, s, action, nestedD);
	}
}
