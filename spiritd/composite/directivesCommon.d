/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.composite.directivesCommon;

import spiritd.match;
import spiritd.parser;
import spiritd.composite.composite;
import spiritd.composite.directives;
import spiritd.composite.or;
import spiritd.impl.ctype;
import spiritd.impl.directives;

/**\brief parser which turns off skipping */
class contiguous(parserT) : unary!(parserT, parser!(contiguous!(parserT))) {
	alias	typeof(this)		_thisT;
	alias	unaryParserCategory	_categoryT;
	alias	lexemeGenerator		_generatorT;

	template	result(scannerT) {
		alias	parserResult!(parserT, scannerT)._resultT	_resultT;
	}

	this(parserT p)	{ super(p); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		return contiguousParserParse!(parserResult!(_thisT, scannerT)._resultT)(subject, s);
	}
}

/**\brief generator template for contiguous */
template lexemeGenerator() {
	template result(parserT) {
		alias	contiguous!(parserT)	_resultT;
	}

	contiguous!(parserT)
	generate(parserT)(parser!(parserT) src) {
		return new contiguous!(parserT)(src.derived());
	}

	contiguous!(parserT)
	opIndex(parserT)(parserT src) {
		return new contiguous!(parserT)(src.derived());
	}
}

/**\brief template to determine type of no skip scanner created by contiguous */
template lexemeScanner(scannerT) {
	alias	noSkipPolicy!(scannerT._valueT, scannerT._iterationPolicyT)	noSkipPoliciesT;
	alias	scannerPolicies!(
					noSkipPoliciesT,
					scannerT._matchPolicyT,
					scannerT._actionPolicyT)			scannerPoliciesT;

	alias	scanner!(scannerT._iteratorT, scannerPoliciesT)
														_resultT;
}

struct sLexemeD {
	mixin	lexemeGenerator!();
}
	sLexemeD	lexemeD;

/**\brief iterator policy to convert input stream to lower case */
class inhibitCasePolicy(baseT) : baseT {
	static charT filter(charT)(charT ch) { return cast(charT)tolower(ch); }
}

/**\brief parser which treats input as lower case */
class inhibitCase(parserT) : unary!(parserT, parser!(inhibitCase!(parserT))) {
	alias	typeof(this)			_thisT;
	alias	unaryParserCategory		_categoryT;
	alias	inhibitCaseGenerator	_generatorT;

	this(parserT p) { super(p); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT scan) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		return inhibitCaseParserParse!(resultT)(subject, scan);
	}
}

/**\brief template to determine type of inhibit case scanner created by inhibitCase */
template asLowerScanner(scannerT) {
	alias	inhibitCasePolicy!(scannerT._iterationPolicyT)		inhibCasePoliciesT;
	alias	scannerPolicies!(
					inhibCasePoliciesT,
					scannerT._matchPolicyT,
					scannerT._actionPolicyT)					scannerPoliciesT;

	alias	scanner!(scannerT._iteratorT, scannerPoliciesT)		_resultT;
}

// note inhibitCaseGenerator & asLowerD is in compiler specific file(s) spiritd.ver.directives{v1,v2}

/**\brief parser to choose longest alternative.
	\warning no action refactoring is performed. actions will be called for each successful match
	\remarks does this even make sense without action refactoring? */
class longestAlternative(aT, bT) : binary!(aT, bT, parser!(longestAlternative!(aT, bT))) {
	alias	typeof(this)			_thisT;
	alias	binaryParserCategory	_categoryT;
	alias	longestGenerator		_generatorT;

	this(aT a, bT b) { super(a, b); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;

		s._iteratorT	start = s.first, endLeft;
		resultT			matchLeft = conv(left.parse(s));
		endLeft = s.first;
		s.first = start;
		resultT			matchRight = conv(right.parse(s));

		if(matchLeft.match || matchRight.match) {
			if(matchLeft.length > matchRight.length) {
				s.first = endLeft;
				return matchLeft;
			}
			return matchRight;
		}
		return s.noMatch();
	}
}

/**\brief generator template for longestAlternative
	\todo implement recursive expansion so longestAlternative works with nested ors */
template longestGenerator() {
	template result(aT, bT) {
		alias	longestAlternative!(aT, bT)	_resultT;
	}

	longestAlternative!(aT, bT)
	generate(aT, bT)(or!(aT, bT) src) {
		return new longestAlternative!(aT, bT)(src.left, src.right);
	}

	longestAlternative!(aT, bT)
	generate(aT, bT)(aT a, bT b) {
		return new longestAlternative!(aT, bT)();
	}

	longestAlternative!(aT, bT)
	opIndex(aT, bT)(or!(aT, bT) src) {
		return new longestAlternative!(aT, bT)(src.left, src.right);
	}
}

struct sLongestD {
	mixin	longestGenerator!();
}

	sLongestD	longestD;

/**\brief parser to choose shortest alternative.
	\warning no action refactoring is performed. actions will be called for each successful match
	\remarks does this even make sense without action refactoring? */
class shortestAlternative(aT, bT) : binary!(aT, bT, parser!(shortestAlternative!(aT, bT))) {
	alias	typeof(this)			_thisT;
	alias	binaryParserCategory	_categoryT;
	alias	shortestGenerator		_generatorT;

	this(aT a, bT b) { super(a, b); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;

		s._iteratorT	start = s.first, endLeft;
		resultT			matchLeft = conv(left.parse(s));
		endLeft = s.first;
		s.first = start;
		resultT			matchRight = conv(right.parse(s));

		if(matchLeft.match || matchRight.match) {
			if(matchLeft.length < matchRight.length && matchLeft.match || !matchRight.match) {
				s.first = endLeft;
				return matchLeft;
			}
			return matchRight;
		}
		return s.noMatch();
	}
}

/**\brief generator template for shortestAlternative
	\todo implement recursive expansion so shortestAlternative works with nested ors */
template shortestGenerator() {
	template result(aT, bT) {
		alias	shortestAlternative!(aT, bT)	_resultT;
	}

	shortestAlternative!(aT, bT)
	generate(aT, bT)(or!(aT, bT) src) {
		return new shortestAlternative!(aT, bT)(src.left, src.right);
	}

	shortestAlternative!(aT, bT)
	generate(aT, bT)(aT a, bT b) {
		return new shortestAlternative!(aT, bT)();
	}

	shortestAlternative!(aT, bT)
	opIndex(aT, bT)(or!(aT, bT) src) {
		return new shortestAlternative!(aT, bT)(src.left, src.right);
	}
}

struct sShortestD {
	mixin	shortestGenerator!();
}

	sShortestD	shortestD;

/**\brief parser which imposes a minimum bound on numeric input.
	\details
		this parser is used with numeric parsers when the numeric parse should only match
		when the input number is greater than a minimum bound.
			i.e. the expression minLimitD(200)[intP] will only match input integers
			whose value is greater than or equal to 200
*/
class minBounded(parserT, boundsT) : unary!(parserT, parser!(minBounded!(parserT, boundsT))) {
	alias	typeof(this)					_thisT;
	alias	unaryParserCategory				_categoryT;

	template	result(scannerT) {
		alias	parserResult!(parserT, scannerT)._resultT	_resultT;
	}

	this(parserT p, boundsT min)	{ super(p); _min = min; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		resultT	hit = subject.parse(s);

		if(hit.match && hit.length > 0 && hit.value < _min)
			return conv!(resultT)(s.noMatch());
		return hit;
	}
private:
	boundsT		_min;
}

/**\brief generator struct for minBounded, makes minLimitD(3)[parser] work */
struct minBoundedGenerator(boundsT) {

	minBounded!(parserT, boundsT)
	opIndex(parserT)(parserT p) {
		return new minBounded!(parserT, boundsT)(p, _min);
	}

	boundsT	_min;
}

	minBoundedGenerator!(boundsT)	minLimitD(boundsT)(boundsT min) {
		minBoundedGenerator!(boundsT)	tmp;
		tmp._min = min;
		return tmp;
	}

/**\brief parser which imposes a maximum bound on numeric input.
	\details
		this parser is used with numeric parsers when the numeric parse should only match
		when the input number is less than or equal to a maxium bound.
			i.e. the expression maxLimitD(200)[intP] will only match input integers
			whose value is less than or equal to 200
*/
class maxBounded(parserT, boundsT) : unary!(parserT, parser!(maxBounded!(parserT, boundsT))) {
	alias	typeof(this)					_thisT;
	alias	unaryParserCategory				_categoryT;

	template	result(scannerT) {
		alias	parserResult!(parserT, scannerT)._resultT	_resultT;
	}

	this(parserT p, boundsT max)	{ super(p); _max = max; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		resultT	hit = subject.parse(s);

		if(hit.match && hit.length > 0 && hit.value > _max)
			return conv!(resultT)(s.noMatch());
		return hit;
	}
private:
	boundsT		_max;
}

/**\brief generator struct for maxBounded, makes maxLimitD(3)[parser] work */
struct maxBoundedGenerator(boundsT) {

	maxBounded!(parserT, boundsT)
	opIndex(parserT)(parserT p) {
		return new maxBounded!(parserT, boundsT)(p, _max);
	}

	boundsT	_max;
}

	maxBoundedGenerator!(boundsT)	maxLimitD(boundsT)(boundsT max) {
		maxBoundedGenerator!(boundsT)	tmp;
		tmp._max = max;
		return tmp;
	}

/**\brief parser which imposes bounds on numeric input.
	\details
		this parser is used with numeric parsers when the numeric parse should only match
		when the input number is inclusively between 2 bounds.
			i.e. the expression limitD(100, 200)[intP] will only match input integers
			whose value is 100 <= input <= 200
*/
class bounded(parserT, boundsT) : unary!(parserT, parser!(bounded!(parserT, boundsT))) {
	alias	typeof(this)					_thisT;
	alias	unaryParserCategory				_categoryT;

	template	result(scannerT) {
		alias	parserResult!(parserT, scannerT)._resultT	_resultT;
	}

	this(parserT p, boundsT min, boundsT max)	{ super(p); _min = min; _max = max; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias	parserResult!(_thisT, scannerT)._resultT	resultT;
		resultT	hit = subject.parse(s);

		if(hit.match && hit.length > 0)
			if(hit.value < _min || hit.value > _max)
				return conv!(resultT)(s.noMatch());
		return hit;
	}
private:
	boundsT		_min;
	boundsT		_max;
}

/**\brief generator struct for maxBounded, makes maxLimitD(3)[parser] work */
struct boundedGenerator(boundsT) {

	bounded!(parserT, boundsT)
	opIndex(parserT)(parserT p) {
		return new bounded!(parserT, boundsT)(p, _min, _max);
	}

	boundsT	_min;
	boundsT	_max;
}

	boundedGenerator!(boundsT)	limitD(boundsT)(boundsT min, boundsT max) {
		boundedGenerator!(boundsT)	tmp;
		tmp._min = min;
		tmp._max = max;
		return tmp;
	}
