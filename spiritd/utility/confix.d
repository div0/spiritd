/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 2002-2003 Hartmut Kaiser

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.utility.confix;

import spiritd.factory;
import spiritd.parser;
import spiritd.primitives;
import spiritd.composite.kleeneStar;
import spiritd.composite.or;
import spiritd.impl.confix;
import spiritd.meta.asParser;

/**\brief parses a sequence of 3 matches.
	\details
		this class may be used to parse structures, where the opening part is possibly
		contained in the expression part and the whole sequence is only parsed after
		seeing the closing part matching the first opening subsequence. */
///			Example: C-comments:
///			/* This is a C-comment */
class confixParser(openT, exprT, closeT, categoryT, nestedT, lexemeT) :
			parser!(confixParser!(openT, exprT, closeT, categoryT, nestedT, lexemeT)) {
	alias	typeof(this)	_thisT;

	this(openT o, exprT e, closeT c) { _o = o; _e = e; _c = c; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		return confixParserType!(categoryT).parse(nestedT(), lexemeT(), this, s, _o, _e, _c);
	}

private:
	openT	_o;
	exprT	_e;
	closeT	_c;
}

/**\brief
		confix parser generator template,
		used to make constructing 'correct' confix parsers easier
	\details
		This is a helper for generating a correct confix_parser<> from
		auxiliary parameters. There are the following types supported as
		parameters yet: parsers, single characters and strings (see
		as_parser).

		If the body parser is an action_parser_category type parser (a parser
		with an attached semantic action) we have to do something special. This
		happens, if the user wrote something like:

			confixP(open, body[f], close)

		where 'body' is the parser matching the body of the confix sequence
		and 'f' is a functor to be called after matching the body. If we would
		do nothing, the resulting code would parse the sequence as follows:

			start >> (body[f] - close) >> close

		what in most cases is not what the user expects.
		(If this _is_ what you've expected, then please use the confix_p
		generator function 'direct()', which will inhibit
		re-attaching the actor to the body parser).

		To make the confix parser behave as expected:

			start >> (body - close)[f] >> close

		the actor attached to the 'body' parser has to be re-attached to the
		(body - close) parser construct, which will make the resulting confix
		parser 'do the right thing'. This refactoring is done by the help of
		the refactoring parsers (see the files refactoring.[hi]pp).

		Additionally special care must be taken, if the body parser is a
		unary_parser_category type parser as

			confixP(open, *anycharP, close)

		which without any refactoring would result in

			start >> (*anycharP - close) >> close

		and will not give the expected result (*anycharP will eat up all the
		input up to the end of the input stream). So we have to refactor this
		into:

			start >> *(anycharP - close) >> close

		what will give the correct result.

		The case, where the body parser is a combination of the two mentioned
		problems (i.e. the body parser is a unary parser  with an attached
		action), is handled accordingly too:

			confix_p(start, (*anycharP)[f], end)

		will be parsed as expected:

			start >> (*(anycharP - end))[f] >> end.
*/

struct confixParserGen(nestedT, lexemeT) {

	template parenOpResult(startT, exprT, endT) {
		alias
			confixParser!(
				asParser!(startT)._type,
				asParser!(exprT)._type,
				asParser!(endT)._type,
				asParser!(exprT)._type._categoryT,
				nestedT,
				lexemeT
			) _resultT;
	}

	parenOpResult!(startT, exprT, endT)._resultT
	opCall(startT, exprT, endT)(startT start, exprT expr, endT end) {
		alias	parenOpResult!(startT, exprT, endT)._resultT	returnT;
		return new returnT(
			asParser!(startT).convert(start),
			asParser!(exprT).convert(expr),
			asParser!(endT).convert(end)
		);
	}

	// generator for confix parsers which have action attached to exprT.
	// that is create a confix parser the above w/o refactoring
	template directResult(startT, exprT, endT) {
		alias
			confixParser!(
				asParser!(startT),
				asParser!(exprT),
				asParser!(endT),
				plainParserCategory,
				nestedT,
				lexemeT
			) _resultT;
	}

	directResult!(startT, exprT, endT)._resultT
	direct(startT, exprT, endT)(startT start, exprT expr, endT end) {
		alias	directResult!(startT, exprT, endT)._resultT	resultT;
		return new resultT(
			asParser!(startT).convert(start),
			asParser!(exprT).convert(expr),
			asParser!(endT).convert(end)
		);
	}
}

confixParserGen!(nonNested, nonLexeme)	confixP;

/**\brief comments are special types of confix parser
	\details
		Comment parser generator template. This is a helper for generating a
		correct confix_parser<> from auxiliary parameters, which is able to
		parse comment constructs: (startToken >> Comment text >> endToken).

		There are the following types supported as parameters yet: parsers,
		single characters and strings (see asParser).

		There are two diffenerent predefined comment parser generators
		(commentP and commentNestP, see below), which may be used for
		creating special comment parsers in two different ways.

		If these are used with one parameter, a comment starting with the given
		first parser parameter up to the end of the line is matched. So for
		instance the following parser matches C++ style comments:

			commentP("//").

		If these are used with two parameters, a comment starting with the
		first parser parameter up to the second parser parameter is matched.
		For instance a C style comment parser should be constrcuted as:
*/
///	commentP("/*", "*/").
/**
		Please note, that a comment is parsed implicitly as if the whole
		commentP(...) statement were embedded into a lexemeD[] directive.
*/

struct commentParserGen(nestedT) {
	// Generic generator function for creation of concrete comment parsers
	// from an open token. The newline parser eolP is used as the
	// closing token.
	struct parenOp1Result(startT) {
		alias
			confixParser!(
				asParser!(startT)._type,
				kleeneStar!(anycharParser),
				spiritd.composite.or.or!(eolParser, endParser),
				unaryParserCategory,	// there is no action to re-attach
				nestedT,
				isLexeme				// insert implicit lexemeD[]
			) _resultT;
	}

	parenOp1Result!(startT)._resultT
	opCall(startT)(startT start) {
		alias	parenOp1Result!(startT)._resultT	returnT;
		return new returnT(
			asParser!(startT).convert(start),
			star(anycharP),
			spiritd.factory.or(eolP, endP)
		);
	}

	// Generic generator function for creation of concrete comment parsers
	// from an open and a close tokens.
	template parenOp2Result(startT, endT) {
		alias
			confixParser!(
				asParser!(startT)._type,
				kleeneStar!(anycharParser),
				asParser!(endT)._type,
				unaryParserCategory,	// there is no action to re-attach
				nestedT,
				isLexeme				// insert implicit lexemeD[]
			) _resultT;
	}

	parenOp2Result!(startT, endT)._resultT
	opCall(startT, endT)(startT start, endT end) {
		alias	parenOp2Result!(startT, endT)._resultT	returnT;

		return new returnT(
			asParser!(startT).convert(start),
			star(anycharP),
			asParser!(endT).convert(end)
			);
	}
}

	commentParserGen!(nonNested)	commentP;

/**\brief parses nested comments, e.g. pascal comments: { This is a { nested } PASCAL-comment } */
class commentNestParser(openT, closeT) : parser!(commentNestParser!(openT, closeT)) {
	alias	typeof(this)	_thisT;

	this(openT open, closeT close)	{ _open = open; _close = close; } 

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		scope p =
			seq(
				seq(
					open,
					kleeneStar(
						or(
							this,
							diff(anycharP, close)
						)
						
					)
				),
				close
			);
		return doParse(p, s);
	}

private:

	parserResult!(_thisT, scannerT)._resultT
	doParse(parserT, scannerT)(parserT p, scannerT s) {
		return contiguousParserParse!(parserResult!(parserT, scannerT)._resultT)(p, s);
	}

	openT	_open;
	closeT	_close;
}

/**\brief predefined nested comment parser generator */

template commentNestPResult(openT, closeT) {
	alias
		commentNestParser!(
			asParser!(openT)._type,
			asParser!(closeT)._type
		)	_resultT;
}

	commentNestPResult!(openT, closeT)._resultT
	commentNestP(openT, closeT)(openT open, closeT close) {
		alias	commentNestPResult!(openT, closeT)._resultT		result_t;

		return new resultT(
				asParser!(openT).convert(open),
				asParser!(closeT).convert(close)
			);
	}
