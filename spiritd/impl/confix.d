/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 2002-2003 Hartmut Kaiser

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.confix;

import spiritd.factory;
import spiritd.parser;
import spiritd.impl.directives;
import spiritd.meta.refactoring;

struct isNested {}
struct nonNested {}

struct isLexeme {}
struct nonLexeme {}

//  implicitly insert a lexeme_d into the parsing process

template selectConfixParseLexeme(T : isLexeme) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT)(parserT p, scannerT s) {
		alias  parserResult!(parserT, scannerT)._resultT	resultT;
		return contiguousParserParse!(resultT)(p, s);
	}
}

template selectConfixParseLexeme(T : nonLexeme) {
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT)(parserT p, scannerT s) {
		return p.parse(s);
	}
}

//  parse confix sequences with refactoring

template selectConfixParseRefactor(T : isNested) {
	parserResult!(parserT, scannerT)._resultT
	parse(lexemeT, parserT, scannerT, openT, exprT, closeT)
		(lexemeT, parserT this_, scannerT s, openT open, exprT expr, closeT close) {

		alias	refactorActionGen!(refactorUnaryGen!())	refactorT;
		scope	refactorBodyD = new refactorT(refactorUnaryD);
		scope	p =
			seq(
				seq(
					open,
					or(this_, refactorBodyD[diff(expr, close)])
				),
				close
			);
		return	selectConfixParseLexeme!(lexemeT).parse(p, s);
	}
}

template selectConfixParseRefactor(T : nonNested) {
	parserResult!(parserT, scannerT)._resultT
	parse(lexemeT, parserT, scannerT, openT, exprT, closeT)
		(lexemeT, parserT /*this_*/, scannerT s, openT open, exprT expr, closeT close) {

		alias 	refactorActionGen!(refactorUnaryGen!())	refactorT;
		scope	refactorBodyD = new refactorT(refactorUnaryD);
		scope	p = 
			seq(
				seq(
					open,
					refactorBodyD[diff(expr, close)]
				),
				close
			);
		return	selectConfixParseLexeme!(lexemeT).parse(p, s);
	}
}

//  parse confix sequences without refactoring

template selectConfixParseNoRefactor(T : isNested) {
	parserResult!(parserT, scannerT)._resultT
	parse(lexemeT, parserT, scannerT, openT, exprT, closeT)
		(lexemeT, parserT this_, scannerT s, openT open, exprT expr, closeT close) {

		scope	p = 
			seq(
				seq(
					open,
					or(this_, diff(expr, close))
				),
				close
			);
		return	selectConfixParseLexeme!(lexemeT).parse(p, s);
	}
}

template selectConfixParseNoRefactor(T : nonNested) {
	parserResult!(parserT, scannerT)._resultT
	parse(lexemeT, parserT, scannerT, openT, exprT, closeT)
		(lexemeT, parserT /*this_*/, scannerT s, openT open, exprT expr, closeT close) {

		scope	p = 
			seq(
				seq(
					open,
					diff(expr, close)
				),
				close
			);
		return selectConfixParseLexeme!(lexemeT).parse(p, s);
	}
}

template confixParserType(categoryT) {
	parserResult!(parserT, scannerT)._resultT
	parse(nestedT, lexemeT, parserT, scannerT, openT, exprT, closeT)
		(nestedT, lexemeT lexeme, parserT  this_, scannerT  scan, openT  open, exprT  expr, closeT  close) {
		return selectConfixParseRefactor!(nestedT).parse(lexeme, this_, scan, open, expr, close);
	}
}

template confixParserType(categoryT : plainParserCategory) {
	parserResult!(parserT, scannerT)._resultT
	parse(nestedT, lexemeT, parserT, scannerT, openT, exprT, closeT)
		(nestedT, lexemeT lexeme, parserT this_, scannerT scan, openT  open, exprT  expr, closeT  close) {
		return selectConfixParseNoRefactor!(nestedT).parse(lexeme, this_, scan, open, expr, close);
	}
}
