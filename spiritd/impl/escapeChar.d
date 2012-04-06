/*=============================================================================
	spiritd - Copyright (c) 2009 s.d.hammett
		a D2 parser library ported from boost::spirit
			Copyright (c) 2001-2003 Daniel Nuffer

	Use, modification and distribution is subject to the Boost Software
	License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
	http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.impl.escapeChar;

import f = spiritd.factory;
import spiritd.match;
import spiritd.numerics;
import spiritd.parser;
import spiritd.primitives;
import spiritd.scanner;
import spiritd.composite.composite;
import spiritd.composite.difference;
import spiritd.composite.directives;
import spiritd.composite.or;
import spiritd.composite.sequence;
import spiritd.impl.ctype;

enum EscapeFlags {
	cEscapes,
	lexEscapes
}

template escapeCharActionParse(int flags, charT) {

	parserResult!(parserT, scannerT)._resultT
	parse(scannerT, parserT)(scannerT s, parserT p)
	{
		alias	parserResult!(parserT, scannerT)._resultT	resultT;
		alias	scannerT._iteratorT							iteratorT;

		if(s.first != s.last) {
			iteratorT	save = s.first;
			resultT		hit = p.subject.parse(s);

			if(hit.match()) {
				charT		unescaped;
				iteratorT	curr = save;

				if(*curr == '\\') {
					++curr;
					switch (*curr) {
					case 'b':   unescaped = '\b';   ++curr; break;
					case 't':   unescaped = '\t';   ++curr; break;
					case 'n':   unescaped = '\n';   ++curr; break;
					case 'f':   unescaped = '\f';   ++curr; break;
					case 'r':   unescaped = '\r';   ++curr; break;
					case '"':   unescaped = '"';    ++curr; break;
					case '\'':  unescaped = '\'';   ++curr; break;
					case '\\':  unescaped = '\\';   ++curr; break;
					case 'x': case 'X': {
						charT	hex = 0;
						charT	lim = charT.max >> 4;

						++curr;

						while(curr != s.last) {
							charT	c = *curr;

							if(hex > lim && isxdigit(c)) {
								// overflow detected
								s.first = save;
								return conv!(resultT)(s.noMatch());
							}

							if(isdigit(c)) {
								hex <<= 4;
								hex |= c - '0';
								++curr;
							}
							else if(isxdigit(c)) {
								hex <<= 4;
								c = toupper(c);
								hex |= c - 'A' + 0xA;
								++curr;
							}
							else
							{
								break; // reached the end of the number
							}
						}
						unescaped = hex;
					}
					break;

					case '0': case '1': case '2': case '3':
					case '4': case '5': case '6': case '7': {
						charT	oct = 0;
						charT	lim = charT.max >> 3;
						while(curr != s.last) {
							charT	c = *curr;

							if(oct > lim && (c >= '0' && c <= '7')) {
								// overflow detected
								s.first = save;
								return conv!(resultT)(s.noMatch());
							}

							if (c >= '0' && c <= '7') {
								oct <<= 3;
								oct |= c - '0';
								++curr;
							}
							else
							{
								break; // reached end of digits
							}
						}
						unescaped = oct;
					}
					break;

					default:
						if(flags & EscapeFlags.cEscapes) {
							// illegal C escape sequence
							s.first = save;
							return conv!(resultT)(s.noMatch());
						}
						unescaped = *curr++;
					break;
					}
				}
				else
				{
					unescaped = *curr++;
				}
				s.first = curr;
				s.invokeAction(p.predicate(), unescaped, save, s.first);
				return hit;
			}
		}
		return conv!(resultT)(s.noMatch()); // overflow detected
	}
}

/**\brief parser for a backslash escaped character.
	\details this is a cac way of doing things, but it's how spirit does it
		and makes for a useful test case (which is probably why spirit did it this way).
		to be revised. */
struct escapeCharParse(charT) {
	static
	parserResult!(parserT, scannerT)._resultT
	parse(parserT, scannerT)(scannerT s) {
		static assert(is(char == charT) || is(wchar == charT) || is(dchar == charT));

		alias	parserResult!(parserT, scannerT)._resultT			resultT;
		alias	uintParser!(charT, 8, 1, charT.sizeof / 3 + 1)	octParserT;
		alias	uintParser!(charT, 16, 1, charT.sizeof / 4 + 1)	hexParserT;

		alias
			or!(
				difference!(anycharParser, chLit!(charT)),
				sequence!(
					chLit!(charT),
					or!(
						or!(
							octParserT,
							sequence!(inhibitCase!(chLit!(charT)), hexParserT)
						),
						difference!(
							difference!(
								anycharParser,
								inhibitCase!(chLit!(charT))),
							octParserT
						)
					)
				)
			) parserT;

		static	parserT	p;

		if( p is null )
			p = f.or(
					f.diff(anycharP, chP!(charT)('\\')),
					f.seq(
						chP!(charT)('\\'),
						f.or(
							f.or(
								new octParserT,
								f.seq(
									asLowerD[cast(charT)('x')],
									new hexParserT
								)
							),
							f.diff(
								f.diff(
									anycharP,
									asLowerD[cast(charT)('x')]
								),
								new octParserT
							)
						)
					)
				);

		return conv!(resultT)(p.parse(s));
	}
}
