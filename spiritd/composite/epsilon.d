/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
		Copyright (c) 1998-2003 Joel de Guzman
		Copyright (c) 2002-2003 Martin Wille

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.epsilon;

import spiritd.match;
import spiritd.nil;
import spiritd.parser;
import spiritd.scanner;
import spiritd.composite.composite;

class conditionParser(condT, bool _positive = true) {
	alias	typeof(this)	_thisT;

	this(condT cond) {_cond = cond; }

	parserResult!(_thisT, scannerT)._resultT
	parser(scannerT)(scannerT s) {
		if(_positive == _cond.test())
			return s.emptyMatch();
		return s.noMatch();
	}

	conditionParser!(condT, !_positive)
	negate() {
		return new conditionParser!(condT, !_positive)(_cond);
	}

private:
	condT	_cond;
}

/*conditionParser!(contT, !_positive)
negate(condT, bool _positive)(conditionParser!(condT, _positive) p) {
	return p.negate();
}*/

class emptyMatchParser(subjectT) : unary!(subjectT, parser!(emptyMatchParser!(subjectT))) {
	alias	typeof(this)			_thisT;
	alias	emptyMatchGenerator		_generatorT;

	this(subjectT p) { super(p); }

	template	result(scannerT) {
		alias	matchResult!(scannerT, nilT)._resultT	_resultT;
	}

	parserResult!(_thisT, scannerT)._resultT
	parser(scannerT)(scannerT s) {
		alias			noActionsPolicy!(scannerT)	noActionsT;
		s._iteratorT	save = s.first;

		scope noActionsScanner = s.changeActionPolicies!(noActionsT)(s);
		bool	matches = subject.parse(noActionsScanner);

		if(matches) {
			s.first = save;
			return s.emptyMatch();
		}
		return s.noMatch();
	}
}

template emptyMatchGenerator() {
	template result(aT) {
		alias	emptyMatchParser!(aT)		_resultT;
	}

	emptyMatchParser!(aT)
	generate(aT)(aT a) {
		return new emptyMatchParser!(aT)(a.derived());
	}
}

class epsilonParser : parser!(epsilonParser) {
	alias	typeof(this)	_thisT;

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		return s.emptyMatch();
	}
}

	epsilonParser	epsP;
	static this() {
		epsP = new epsilonParser;
	}
