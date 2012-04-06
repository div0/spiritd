/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2002 Joel de Guzman

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.scanner;

import std.stdint;

import spiritd.match;
import spiritd.nil;
import spiritd.impl.debugging;

import std.utf;

/**\brief iterator policy is used to provide the actual code which handles the iterator stored by the scanner.
	\details by default we use standard string access idiom of indexing through the slice */
class defIterationPolicy(charT) {
	alias	charT	_valueT;

	static void advance(scannerT)(scannerT scan) 		{ ++(scan._curr); }
	static bool atEnd(scannerT)(scannerT scan)		{ return scan._curr == scan._end; }
	static T	filter(T)(T ch)							{ return ch; }
	static void skip(scannerT)(scannerT s) 			{}

	static scannerT._valueT
		get(scannerT)(scannerT scan)					{ return *(scan._curr); }

	// utf support, only supports decoding from narrow to wider character types
	static dchar decode(scannerT)(scannerT scan) {
		static if(is(scannerT._valueT == dchar))
			return *(scan._curr);
		size_t indx = 0;
		return std.utf.decode(scan.sliceToEnd(), indx);
	}
	static void	 advanceEncoded(scannerT)(scannerT scan) {
		static if(is(scannerT._valueT == dchar))
			++(scan._curr);
		else
			scan._curr += stride(scan.sliceToEnd(), 0);
	}
}

/**\brief matchPolicy mixin, policy which specifies the return types used to indicate match results */
class defMatchPolicy {

	alias	std.stdint.intptr_t		_lengthT;
	alias	std.stdint.uintptr_t	_sizeT;

	Match!(nilT)	noMatch() 		{ return Match!(nilT)(-1); }
	Match!(nilT)	emptyMatch()	{ return Match!(nilT)(0); }

	Match!(T)		createMatch(T, iteratorT)(in _lengthT len, in T val, in iteratorT first, in iteratorT last) {
		return Match!(T)(len, val);
	}

	// specialisation when creating a match!(nilT). ignore the val earlier than having an appropriate match!(nilT) ctor
	Match!(T)		createMatch(T : nilT, iteratorT)(in _lengthT len, in T val, in iteratorT first, in iteratorT last) {
		return Match!(T)(len);
	}

	void concatMatch(match0T, match1T)(ref match0T lhs, ref match1T rhs) {
		lhs.concat(rhs);
	}
}

/**\brief default action policy. ie call the action. */
class defActionPolicy(iteratorT) {
	alias	iteratorT	_iteratorT;

	void	invokeAction(actionT, attributeT)(actionT a, attributeT val, _iteratorT first, _iteratorT last) {
		a(val);
	}
	void	invokeAction(actionT, attributeT : nilT)(actionT a, attributeT val, _iteratorT first, _iteratorT last) {
		a(first, last);
	}
}

/**\brief meta function to determination the match type for a given attribute */
template matchResult(alias matchPolicyT, attributeT) {
	alias	matchPolicyT.result!(attributeT)._resultT	_resultT;
}

/**\brief */
template scannerPolicies(iterationPolicyT, matchPolicyT, actionPolicyT) {
	alias	iterationPolicyT	_iterationPolicyT;
	alias	matchPolicyT		_matchPolicyT;
	alias	actionPolicyT		_actionPolicyT;
}

template iteratorValueType(T : T*) {
	alias	T	_resultT;
}

/**\brief object which controls extraction of input from source */
final class scanner(iter, alias scannerPoliciesT) {
	alias	scannerPoliciesT._iterationPolicyT		_iterationPolicyT;
	alias	scannerPoliciesT._matchPolicyT			_matchPolicyT;
	alias	scannerPoliciesT._actionPolicyT			_actionPolicyT;

	alias	typeof(this)				_thisT;
	alias	_iterationPolicyT._valueT	_valueT;
	alias	iter						_iteratorT;

	this() {
		_iterP = new _iterationPolicyT;
		_matchP = new _matchPolicyT;
		_actionP = new _actionPolicyT;
	}

	this(_iteratorT curr, _iteratorT end) {
		_curr = curr;
		_end = end;
		this();
	}

	this(_iterationPolicyT i, _matchPolicyT m , _actionPolicyT a, _iteratorT curr, _iteratorT end) {
		_iterP = i;
		_matchP = m;
		_actionP = a;
		_curr = curr;
		_end = end;
	}

	template	result(attributeT)	{
		alias	Match!(attributeT)	_resultT;
	}

	alias	_matchPolicyT._lengthT	_lengthT;
	alias	_matchPolicyT._sizeT	_sizeT;

	///\name access to source data, methods which forward to _iterationPolicyT
	//@{
		bool		atEnd() 		{ return _iterP.atEnd(this); }
		_valueT		get()			{ return opStar(); }
		_valueT		opStar()		{ return _iterP.filter(_iterP.get(this)); }
		void		opPostInc()		{ _iterP.advance(this); }
		void		skip(scannerT)(scannerT s)	{ _iterP.skip(s); }

		// utf support
		dchar		decode()			{ return _iterP.decode(this); }
		void		advanceEncoded()	{ _iterP.advanceEncoded(this); }

	//@}

	///\name methods which forward to _matchPolicyT
	//@{
		Match!(nilT)	noMatch() 		{ return _matchP.noMatch(); }
		Match!(nilT)	emptyMatch()	{ return _matchP.emptyMatch(); }

		Match!(T)		createMatch(T, iteratorT)(in _lengthT len, in T val, in iteratorT first, in iteratorT last) {
			return _matchP.createMatch!(T, iteratorT)(len, val, first, last);
		}

		Match!(T)		createMatch(T : nilT, iteratorT)(in _lengthT len, in T val, in iteratorT first, in iteratorT last) {
			return _matchP.createMatch!(T, iteratorT)(len, val, first, last);
		}

	//	static	Match!(T)		groupMatch(T, iteratorT)(in std.size_t len, in T val, iteratorT first, iteratorT last) {
	//		return new match!(T)(len, val);
	//	}

		void concatMatch(match0T, match1T)(ref match0T lhs, ref match1T rhs) {
			return _matchP.concatMatch!(match0T, match1T)(lhs, rhs);
		}
	//@}

	///\name methods which forward _actionPolicyT
	//@{
		void	invokeAction(actionT, attributeT)(actionT a, attributeT val, _iteratorT first, _iteratorT last) { _actionP.invokeAction!(actionT, attributeT)(a, val, first, last); }
		void	invokeAction(actionT, attributeT : nilT)(actionT a, attributeT val, _iteratorT first, _iteratorT last) { _actionP.invokeAction!(actionT, attributeT)(a, val, first, last); }
	//@}

	/**\brief create a new scanner that has different iteration policies */
	static scanner!(_iteratorT, scannerPolicies!(newIterPoliciesT, _matchPolicyT, _actionPolicyT))
	changeIterPolicies(newIterPoliciesT)(_thisT src, newIterPoliciesT iterPol) {
		auto	n = new scanner!(_iteratorT, scannerPolicies!(newIterPoliciesT, _matchPolicyT, _actionPolicyT))(iterPol, src._matchP, src._actionP, src._curr, src._end);
		return n;
	}

	/**\brief create a new scanner that has different iteration policies */
	static scanner!(_iteratorT, scannerPolicies!(_iterationPolicyT, _matchPolicyT, newActionPoliciesT))
	changeActionPolicies(newActionPoliciesT)(_thisT src, newActionPoliciesT actionPol) {
		auto	n = new scanner!(_iteratorT, scannerPolicies!(_iterationPolicyT, _matchPolicyT, newActionPoliciesT))(src._iterP, src._matchP, actionPol, src._curr, src._end);
		return n;
	}

	///\name accessors
	//@{
	_iteratorT		first() 				{ return _curr; }
	void			first(_iteratorT i)		{ _curr = i; }
	_iteratorT		last()					{ return _end; }
	void			last(_iteratorT i)		{ _end = i; }

	immutable(_valueT)[]		sliceToEnd()			{ return _curr[0 .. (_end - _curr)]; }
	//@}

private:
	_iterationPolicyT	_iterP;
	_matchPolicyT		_matchP;
	_actionPolicyT		_actionP;
	_iteratorT	_curr, _end;
}
