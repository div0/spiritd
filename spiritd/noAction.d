/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 1998-2003 Joel de Guzman
			Copyright (c) 2003 Vaclav Vesely

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.noAction;

import spiritd.nil;
import spiritd.scanner;

class noActionPolicy(iteratorT) {
	alias	iteratorT	_iteratorT;

	void	invokeAction(actionT, attributeT)(actionT a, attributeT val, _iteratorT first, _iteratorT last) {}
	void	invokeAction(actionT, attributeT : nilT)(actionT a, attributeT val, _iteratorT first, _iteratorT last) {}
}
