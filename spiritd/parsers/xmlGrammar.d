/*=============================================================================
	spiritd - Copyright (c) 2010 s.d.hammett
		a D2 parser library ported from boost::spirit

	Parsers useful for xml processing.
	\see http://www.w3.org/TR/2008/REC-xml-20081126/

	Distributed under the Boost Software License, Version 1.0. (See accompanying
	file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

module spiritd.parsers.xmlGrammar;

import spiritd.factory;
import spiritd.grammar;
import spiritd.parsers.xml;
import spiritd.primitives;
import spiritd.rule;
import spiritd.util;
import spiritd.composite.directives;
import spiritd.utility.confix;

import std.stdio;

void parse(string input) {
	scope	grmmr = new svgGrammar;
	scope	space = new whiteSpace;
	auto	m = spiritd.parse.parse(input, grmmr, space);

	writefln("match length: %d", m.length);
	writefln(m._end[0 .. 10]);
}

/**\brief xml 1.0 parser. \see http://www.w3.org/TR/2008/REC-xml-20081126/ */
class svgGrammar : grammar!(svgGrammar) {

	static string	_lt = "<";
	static string	_gt = ">";

	struct definition(scannerT) {
		alias	rule!(scannerT)		rT;

		rT	start(svgGrammar outer) {
			assert(outer !is null, "passed null reference as containing grammar!");
			_outer = outer;
			return create();
		}

	private:
		svgGrammar	_outer;
		rT	_element, _content;

		auto	nameStartChar() {
			return
				or(
					or(
						or(
							or(
								or(
									chRangeP('a', 'z'),
									chRangeP('A', 'Z')
								),
								new chRange!(dchar)('\u0370', '\u037d')
							),
							or(
								chP(':'), chP('_')
							)
						),
						or(
							or(
								new chRange!(dchar)('\U00010000', '\U000EFFFF'),	// 917503
								new chRange!(dchar)('\u3001', '\ud7ff')			// 43006
							),
							or(
								new chRange!(dchar)('\u037f', '\u1fff'),			// 7296
								new chRange!(dchar)('\uf900', '\ufdcf')			// 1231
							)
						)
					),
					or(
						or(
							or(
								new chRange!(dchar)('\u2c00', '\u2fef'),			// 1007
								new chRange!(dchar)('\ufdf0', '\ufffd')			// 525
							),
							or(
								new chRange!(dchar)('\u2070', '\u218f'),			// 287
								new chRange!(dchar)('\xf8', '\u02ff')				// 207
							)
						),
						or(
							or(
								new chRange!(dchar)('\xd8', '\xf6'),				// 30
								new chRange!(dchar)('\xc0', '\xd6')				// 22
							),
							new chRange!(dchar)('\u200c', '\u200d')			// 1
						)
					)
				);
		}

		auto	nameChar() {
			return
				or(
					or(
						or(
							or(
								chRangeP('0', '9'),
								chP('-')
							),
							chP('.')
						),
						nameStartChar()
					),
					or(
						new chLit!(dchar)('\xb7'),
						or(
							new chRange!(dchar)('\u0300', '\u036f'),
							new chRange!(dchar)('\u203f', '\u2040')
						)
					)
				);
		}

		auto	name() {
			return		lexemeD[seq(nameStartChar(), star(nameChar))];
		}

		auto	predefinedEntities() {
			return
				or(
					or(
						strLitP("&lt;"),
						strLitP("&gt;")
					),
					or(
						or(
							strLitP("&amp;"),
							strLitP("&quot;")
						),
						strLitP("&apos")
					)
				);
		}

		auto	entityRef() {
			return
				seq(
					chP('&'),
					seq(
						name(),
						chP(';')
					)
				);
		}

		auto	charRef() {
			return
				or(
					lexemeD[
						seq(
							strLitP("&#"),
							seq(
								positive(alphaP),
								chP(';')
							)
						)
					],
					lexemeD[
						seq(
							strLitP("&#x"),
							seq(
								positive(
									or(
										alphaP,
										or(
											chRangeP('a', 'f'),
											chRangeP('A', 'F')
										)
									)
								),
								chP(';')
							)
						)
					]
				);
		}

		auto	reference() {
			return
				or(
					or(
						predefinedEntities(),
						entityRef()
					),
					charRef()
				);
		}

		auto	charData() {
			return
				lexemeD[
					star(
						diff(
							anycharP,
							or(
								or(chP('<'), chP('&')),
								strLitP("]]>")
							)
						)
					)
				][&_outer.charData];
		}

		auto	cdataSection() {
			auto	start = strLitP("<![CDATA[");
			auto	end = strLitP("]]>");
			auto	content = diff(star(anycharP), end)[&_outer.cdataSectionContent];
			return
				seq(seq(start, content),end);
		}

		auto	attributeValue() {
			auto	attVal = star(anycharP)[&_outer.attributeValue];
			return
				or(
					lexemeD[confixP('"', attVal, '"')],
					lexemeD[confixP('\'', attVal, '\'')]
				);
		}

		auto	attribute() {
			return
				seq(
					name()[&_outer.attributeName],
					seq(
						chP('='),
						attributeValue()
					)
				);
		}

		auto	tagMain(endT)(endT end) {
			return
				seq(
					seq(
						chP('<'),
						name()[&_outer.tag]
					),
					seq(
						star(attribute()),
						end
					)
				);
		}

		auto	tag() {
			return
				tagMain(chP('>'));
		}

		auto	emptyTag() {
			auto	end = lexemeD[seq(chP('/'), chP('>'))];
			return tagMain(end);
		}

		auto	endTag() {
			return
				seq(
					lexemeD[seq(chP('<'), chP('/'))],
					seq(
						name(),
						chP('>')
					)
				)[&_outer.endTag];
		}

		auto	xmlCharacters() {
			return
				seq(
					seq(
						or(chP('x'), chP('X')),
						or(chP('m'), chP('M'))
					),
					or(chP('l'), chP('l'))
				);
		}

		auto	xmlDecl() {
			auto	end = lexemeD[seq(chP('?'), chP('>'))];
			return
				seq(
					lexemeD[
						seq(
							seq(chP('<'), chP('?')),
							xmlCharacters()
						)
					],
					seq(
						star(diff(anycharP, end))[&_outer.xmlDecl],
						end
					)
				);
		}

		auto	docType() {
			auto	gt = chP('>');
			return
				seq(
					strLitP("<!DOCTYPE"),
					seq(
						star(diff(anycharP, gt))[&_outer.docTypeContent],
						gt
					)
				);
		}

		auto	comment() {
			auto	dashdash = seq(chP('-'), chP('-'));
			auto	start = lexemeD[seq(seq(chP('<'), chP('!')),dashdash)];
			auto	end = lexemeD[seq(dashdash, chP('>'))];
			auto	content = star(diff(anycharP, end))[&_outer.commentContent];

			return
				seq(
					seq(start, content),
					end);
		}

		auto	processingInstruction() {
			auto	nme = diff(name(), xmlCharacters());
			auto	start = lexemeD[seq(seq(chP('<'), chP('?')), nme)];
			auto	end = lexemeD[seq(chP('?'), chP('>'))];
			auto	content = star(diff(anycharP, end))[&_outer.processingInstructionContent];

			return
				seq(
					seq(start, content),
					end);
		}

		auto	misc() {
			return
				or(
					comment(),
					processingInstruction()
				);
		}

		auto	prolog() {
			auto	msc = misc();
			return
				seq(
					seq(
						optional(xmlDecl()),
						star(msc)
					),
					optional(seq(docType(), star(msc)))
				);
		}

		void	content() {
			auto	chDat = charData();
			_content =
				seq(
					optional(chDat),
					star(
						or(
							or(_element, reference()),
							or(
								or(processingInstruction(), comment()),
								cdataSection()
							)
						)
					)
				);
		}

		void	element() {
			_element =
				or(
					emptyTag(),
					seq(
						tag(),
						seq(
							_content,
							endTag()
						)
					)
				);
		}

		rT	create() {
			_element = new rT;
			_content = new rT;
			content();
			element();
			auto	doc = rT.create(seq(prolog(), seq(_element, star(misc()))));
			return doc;
		}
	} // struct definition

private:
	alias	iteratorType!(string)._resultT	_iteratorT;
	alias	char _valueT;

	void	xmlDecl(_iteratorT pBegin, _iteratorT pEnd) {
		string	xml = pBegin[0 .. pEnd - pBegin];
		writefln("xml decl: %s", xml);
	}

	void	commentContent(_iteratorT pBegin, _iteratorT pEnd) {
		string	cnt = pBegin[0 .. pEnd - pBegin];
		writefln("comment content: %s", cnt);
	}

	void	processingInstructionContent(_iteratorT pBegin, _iteratorT pEnd) {
		string	cnt = pBegin[0 .. pEnd - pBegin];
		writefln("comment content: %s", cnt);
	}

	void	docTypeContent(_iteratorT pBegin, _iteratorT pEnd) {
		string	cnt = pBegin[0 .. pEnd - pBegin];
		writefln("comment content: %s", cnt);
	}

	void	tag(_iteratorT pBegin, _iteratorT pEnd) {
		string	tag = pBegin[0 .. pEnd - pBegin];
		writefln("xml tag: %s", tag);
	}

	void	endTag(_iteratorT pBegin, _iteratorT pEnd) {
		string	tag = pBegin[0 .. pEnd - pBegin];
		writefln("end tag: %s", tag);
	}

	void	emptyTag(_iteratorT pBegin, _iteratorT pEnd) {
		writeln("current tag is emptyTag");
	}

	void attributeName(_iteratorT pBegin, _iteratorT pEnd) {
		string	name = pBegin[0 .. pEnd - pBegin];
		writefln("att: %s", name);
	}

	void attributeValue(_iteratorT pBegin, _iteratorT pEnd) {
		string	val = pBegin[0 .. pEnd - pBegin];
		writefln("=\"%s\"", val);
	}

	void	charData(_iteratorT pBegin, _iteratorT pEnd) {
		string	chData = pBegin[0 .. pEnd - pBegin];
		writefln("tag char data content: %s", chData);
	}

	void	cdataSectionContent(_iteratorT pBegin, _iteratorT pEnd) {
		string	chData = pBegin[0 .. pEnd - pBegin];
		writefln("cdata section content: %s", chData);
	}
}
