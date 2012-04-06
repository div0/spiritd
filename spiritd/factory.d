/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.factory;

import spiritd.composite.difference;
//import spiritd.composite.epsilon;
import spiritd.composite.intersection;
import spiritd.composite.kleeneStar;
import spiritd.composite.list;
import la = spiritd.composite.lookAhead;
//import spiritd.composite.noActions;
import spiritd.composite.optional;
import spiritd.composite.or;
import spiritd.composite.positive;
import spiritd.composite.sequence;
import spiritd.composite.sequenceOr;
import spiritd.composite.xor;

difference!(aT, bT)							diff(aT, bT)(aT a, bT b)		{ return new difference!(aT, bT)(a, b); }
intersection!(aT, bT)						intersect(aT, bT)(aT a, bT b)	{ return new intersection!(aT, bT)(a, b); }
kleeneStar!(aT)								star(aT)(aT a)					{ return new kleeneStar!(aT)(a); }
alias	spiritd.composite.list.list			list;
la.lookAhead!(aT, bT, sT)					lookAhead(aT, bT, sT)(aT a, bT b, sT s)	{ return new la.lookAhead!(aT, bT, sT)(a, b, s); }
//auto noAction(aT)(aT a)				{}
spiritd.composite.optional.optional!(aT)	optional(aT)(aT a)				{ return new spiritd.composite.optional.optional!(aT)(a); }
spiritd.composite.or.or!(aT, bT)			or(aT, bT)(aT a, bT b)			{ return new spiritd.composite.or.or!(aT, bT)(a, b); }
spiritd.composite.positive.positive!(aT)	positive(aT)(aT a)				{ return new spiritd.composite.positive.positive!(aT)(a); }
sequence!(aT, bT)							seq(aT, bT)(aT a, bT b)		{ return new sequence!(aT, bT)(a, b); }
sequence!(aT, bT)							seqAnd(aT, bT)(aT a, bT b)		{ return new sequence!(aT, bT)(a, b); }
sequenceOr!(aT, bT)							seqOr(aT, bT)(aT a, bT b)		{ return new sequenceOr!(aT, bT)(a, b); }
spiritd.composite.xor!(aT, bT)				xor(aT, bT)(aT a, bT b)		{ return new spiritd.composite.xor!(aT, bT)(a, b); }
