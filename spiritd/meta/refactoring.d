/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 2002-2003 Hartmut Kaiser

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.meta.refactoring;

import spiritd.action;
import spiritd.parser;
import spiritd.composite.composite;
import spiritd.impl.refactoring;
import spiritd.meta.asParser;

/**\brief refactors a binary parser
	\details
		This helper template allows to attach an unary operation to a newly
		constructed parser, which combines the subject of the left operand of
		the original given parser (binaryT) with the right operand of the
		original binary parser through the original binary operation and
		rewraps the resulting parser with the original unary operator.

		For instance given the parser:
			*some_parser - another_parser

		will be refactored to:
			*(some_parser - another_parser)

		If the parser to refactor is not a unary parser, no refactoring is done at all.
		The original parser should be a binary_parser_category parser,
		else the compilation will fail */ 
class refactorUnaryParser(binaryT, nestedT = nonNestedRefactoring) : parser!(refactorUnaryParser!(binaryT, nestedT)) {
	static	assert(is(binaryT._categoryT : binaryParserCategory), "parser must be a binary parser");

	alias	typeof(this)					_thisT;
	alias	refactorUnaryGen!(nestedT)		_generatorT;
	alias	binaryT._leftT._categoryT		_categoryT;

	this(binaryT binary, nestedT nested)	{ _binary = binary; _nested = nested; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		return refactorUnaryType!(nestedT).parse(this, s, _binary, _nested);
	}

private:
	 asParser!(binaryT)._type	_binary;
	 nestedT					_nested;
};

class refactorUnaryGen(nestedT = nonNestedRefactoring) {

	this(nestedT nested = nonNestedRefactoring())	{ _nested = nested;}

	refactorUnaryParser!(parserT, nestedT)
	opIndex(parserT)(parserT subject) {
		return	new refactorUnaryParser!(parserT, nestedT)(subject.derived(), _nested);
	}

private:
	nestedT	_nested;
};

	refactorUnaryGen!()	refactorUnaryD;
	static this() {
		refactorUnaryD = new refactorUnaryGen!();
	}

/**\brief refactors action of a binary parser
	\details
		This helper template allows to attach an action taken from the left
		operand of the given binary parser to a newly constructed parser,
		which combines the subject of the left operand of the original binary
		parser with the right operand of the original binary parser by means of
		the original binary operator parser.

		For instance the parser:
			some_parser[some_attached_functor] - another_parser

		will be refactored to:
			(some_parser - another_parser)[some_attached_functor]

		If the left operand to refactor is not an action parser, no refactoring
		is done at all.

		The original parser should be a binary_parser_category parser,
		else the compilation will fail */
class refactorActionParser(binaryT, nestedT = nonNestedRefactoring) : parser!(refactorActionParser!(binaryT, nestedT)) {
	static	assert(is(binaryT._categoryT : binaryParserCategory), "parser must be a binary parser");

	alias	typeof(this)					_thisT;
	alias	refactorActionGen!(nestedT)		_generatorT;
	alias	binaryT._leftT._categoryT		_categoryT;

	this(binaryT binary, nestedT nested) { _binary = binary; _nested = nested; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		return refactorActionType!(nestedT).parse(this, s, _binary, _nested);
	}

private:
	asParser!(binaryT)._type	_binary;
	nestedT						_nested;
};

class	refactorActionGen(nestedT = nonNestedRefactoring) {

	this(nestedT nested) { _nested = nested; }

	refactorActionParser!(parserT, nestedT)
	opIndex(parserT)(parserT subject) {
		return new refactorActionParser!(parserT, nestedT)(subject.derived(), _nested);
	}

private:
	nestedT		_nested;
};

	refactorActionGen!()	refactorActionD;
	static this() {
		refactorActionD = new refactorActionGen!(nonNestedRefactoring)(nonNestedRefactoring());
	}

/**\brief attachs an action to both sides of a binary parser
	\details
		This helper template allows to attach an action given separately
		to all parsers, out of which the given parser is constructed and
		reconstructs a new parser having the same structure.

		For instance the parser:
			(some_parser >> another_parser)[some_attached_functor]

		will be refactored to:
			some_parser[some_attached_functor] >> another_parser[some_attached_functor]

		The original parser should be a actionParserCategory parser,
		else the compilation will fail

		If the parser, to which the action is attached is not an binary parser,
		no refactoring is done at all. */

class attachActionParser(actionT, nestedT = nonNestedRefactoring) : parser!(attachActionParser!(actionT, nestedT)) {
	static	assert(is(actionT._categoryT : actionParserCategory), "parser must be an action parser");

	alias	typeof(this)				_thisT;
	alias	attachActionGen!(nestedT)	_generatorT;
	alias	actionT._categoryT 			_categoryT;

	this(actionT actor, nestedT nested) { _actor = actor; _nested = nested; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		return attachActionType!(nestedT).parse(this, s, _actor, _nested);
	}

private:
	asParser!(actionT)._type	_actor;
	nestedT						_nested;
};

class	attachActionGen(nestedT = nonNestedRefactoring) {

	this(nestedT nested = nonNestedRefactoring()) { _nested = nested; }

	attachActionParser!(action!(parserT, actionT), nestedT)
	opIndex(parserT, actionT)(action!(parserT, actionT) actor) {
		return new attachActionParser!(action!(parserT, actionT), nestedT)(actor, _nested);
	}

private:
	nestedT		_nested;
};

	attachActionGen!()	attachActionD;
	static this() {
		attachActionD = new attachActionGen!();
	}
