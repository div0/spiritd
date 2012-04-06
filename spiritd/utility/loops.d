/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2002 Raghavendra Satish
			Copyright (c) 2002 Jeff Westfahl

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.utility.loops;

import spiritd.match;
import spiritd.parser;
import spiritd.composite.composite;

/**\brief fixed loop parser. \note passing pointers to variables is not implemented yet
	\details
		This class takes care of the construct:

			repeatP(exact)[p]

		where 'p' is a parser and 'exact' is the number of times to repeat.
		The parser iterates over the input exactly 'exact' times.
		The parse function fails if the parser does not match the input exactly 'exact' times.

		This class is parametizable and can accept constant arguments
		(e.g. repeatP(5)[p]) as well as pointers to variables (e.g. repeatP(&n)[p]).
*/
class fixedLoop(parserT, exactT) : unary!(parserT, parser!(fixedLoop!(parserT, exactT))) {

	alias	typeof(this)	_thisT;

	this(parserT subject, exactT exact) { super(subject); _exact = exact; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias		parserResult!(_thisT, scannerT)._resultT	resultT;
		resultT		hit = s.emptyMatch();
		s._sizeT	n = _exact;

		for(s._sizeT i = 0; i < n; ++i) {
			scope next = subject().parse(s);

			if(!next.match)
				return s.noMatch();
			s.concatMatch(hit, next);
		}

		return hit;
	}

private:
	exactT	_exact;
}

/**\brief finite loop parser. \note passing pointers to variables is not implemented yet
	\details
		This class takes care of the construct:

			repeatP(min, max) [p]

		where 'p' is a parser, 'min' and 'max' specifies the minimum and maximum iterations
		over 'p'. The parser iterates over the input at least 'min' times and at most
		'max' times. The parse function fails if the parser does not match the input at least
		'min' times and at most 'max' times.

		This class is parametizable and can accept constant arguments
		(e.g. repeatP(5, 10)[p]) as well as pointers to variables
		(e.g. repeatP(&n1, &n2)[p]).
*/
class finiteLoop(parserT, minT, maxT) : unary!(parserT, parser!(finiteLoop!(parserT, minT, maxT))) {
	alias	typeof(this)	_thisT;

	this(parserT subject, minT min, maxT max) { super(subject); _min = min; _max = max; assert(_min <= _max); }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias		parserResult!(_thisT, scannerT)._resultT	resultT;
		resultT		hit = s.emptyMatch();
		s._sizeT	n1 = _min;
		s._sizeT	n2 = _max;

		for(s._sizeT i = 0; i < n2; ++i) {
			s._iteratorT	save = s.first;
			scope			next = conv(subject.parse(s));

			if(!next.match) {
				if(i < n1)
					return s.noMatch();
				s.first = save;
				break;
			}
			s.concatMatch(hit, next);
		}

		return hit;
	}
private:
	minT	_min;
	maxT	_max;
}

/**\brief infinite loop parser. \note passing pointers to variables is not implemented yet
	\details
		This class takes care of the construct:

			repeatP(min, more)[p]

		where 'p' is a parser, 'min' is the minimum iteration over 'p' and more specifies
		that the iteration should proceed indefinitely. The parser iterates over the
		input at least 'min' times and continues indefinitely until 'p' fails or all of the
		input is parsed. The parse function fails if the parser does not match the input at
		least 'min' times.

		This class is parametizable and can accept constant arguments
		(e.g. repeatP(5, more) [p]) as well as references to variables
		(e.g. repeatP(&n, more) [p]).
*/
struct moreT {};

class infiniteLoop(parserT, minT) : unary!(parserT, parser!(infiniteLoop!(parserT, minT))) {
	alias	typeof(this)	_thisT;

	this(parserT subject, minT min, moreT) { super(subject); _min = min; }

	parserResult!(_thisT, scannerT)._resultT
	parse(scannerT)(scannerT s) {
		alias		parserResult!(_thisT, scannerT)._resultT	resultT;
		resultT		hit = s.emptyMatch();
		s._sizeT	n = _min;

		for(s._sizeT i = 0; ; ++i) {
			s._iteratorT	save = s.first;
			scope			next = subject.parse(s);

			if(!next.match) {
				if(i < n)
					return s.noMatch();
				s.first = save;
				break;
			}

			s.concatMatch(hit, next);
		}
		return hit;
	}
private:
	minT	_min;
};

class fixedLoopGen(exactT) {
	this(exactT exact) { _exact = exact; }

	fixedLoop!(parserT, exactT)
	opIndex(parserT)(parserT subject) {	
		return new fixedLoop!(parserT, exactT)(subject.derived, _exact);
	}
private:
	exactT	_exact;
};

class nonFixedLoopGen(minT, maxT) {
	this(minT min, maxT max) { _min = min; _max = max; }

	static if(is(maxT : moreT) )
		infiniteLoop!(parserT, minT)
		opIndex(parserT)(parserT subject) {
			return new infiniteLoop!(parserT, minT)(subject.derived(), _min, _max);
		}
	else
		finiteLoop!(parserT, minT, maxT)
		opIndex(parserT)(parserT subject) {
			return new finiteLoop!(parserT, minT, maxT)(subject.derived(), _min, _max);
		}

private:
	minT	_min;
	maxT	_max;
}

	fixedLoopGen!(exactT)	repeatP(exactT)(exactT exact) {
		return new fixedLoopGen!(exactT)(exact);
	}

	nonFixedLoopGen!(minT, maxT)	repeatP(minT, maxT)(minT min, maxT max) {
		return new nonFixedLoopGen!(minT, maxT)(min, max);
	}
