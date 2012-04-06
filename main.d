import f = spiritd.factory;
import spiritd.match;
import spiritd.nil;
import spiritd.numerics;
import spiritd.primitives;
import spiritd.rule;
import spiritd.scanner;
import spiritd.skipper;
import spiritd.util;
import spiritd.composite.difference;
import spiritd.composite.directives;
import spiritd.composite.epsilon;
import spiritd.composite.intersection;
import spiritd.composite.kleeneStar;
import spiritd.composite.list;
import spiritd.composite.optional;
import spiritd.composite.or;
import spiritd.composite.positive;
import spiritd.composite.sequence;
import spiritd.composite.xor;
import spiritd.meta.asParser;
import spiritd.meta.refactoring;
import spiritd.utility.confix;
import spiritd.utility.escapeChar;
import spiritd.utility.loops;

import std.stdio;

void doubleMe(double d) {
	writefln("double action!, matched %f", d);
}

void fark(char ch) {
	writefln("fark!, matched %s", ch);
}

void intMatch(int i) {
	writefln("intP action: parsed: %d", i);
}

void printMatch(in char *first, in char *last) {
	auto	match = first[0 .. last - first];
	writefln(match);
}

void setString(T)(T scanner, string str) {
	scanner.first = str.ptr;
	scanner.last = str.ptr + str.length;
}

void testComposites() {
	auto	testStr = "ababa a bcde";
	auto	c0 = chP('A');
	auto	c1 = negate(chP('a'));
	auto	c2 = chRangeP('A', 'E');
	auto	c3 = chSeqP("ABC");
	auto	c4 = strLitP("abc");

		auto s = makeScanner(testStr);

		auto seq = new sequence!(typeof(c4), typeof(c0))(c4, c0);
		s.first = testStr.ptr;
		auto r = seq.parse(s);

		writefln("sequence.parse len: %d", r.length);

		auto orParser = new or!(typeof(c2), typeof(c4))(c2, c4);
		s.first = testStr.ptr;
		r = orParser.parse(s);

		writefln("orParser.parse, len: %d", r.length);

		auto star = new kleeneStar!(typeof(c0))(c0);
		s.first = testStr.ptr;
		r = star.parse(s);

		writefln("star.parse, len: %d", r.length);

		auto pos = new positive!(typeof(c0))(c0);
		s.first = testStr.ptr;
		r = pos.parse(s);

		writefln("pos.parse, len: %d", r.length);
		auto inter = new intersection!(typeof(c0), typeof(c2))(c0, c2);
		s.first = testStr.ptr;
		r = inter.parse(s);

		writefln("inter.parse, len: %d", r.length);

		auto opt = new optional!(typeof(c0))(c0);
		s.first = testStr.ptr;
		r = opt.parse(s);

		writefln("opt.parse, len: %d", r.length);

		auto diff = new difference!(typeof(c3), typeof(c4))(c3, c4);
		s.first = testStr.ptr;
		r = diff.parse(s);

		writefln("diff.parse, len: %d", r.length);

		auto zor = new xor!(typeof(c3), typeof(c0))(c3, c0);
		s.first = testStr.ptr;
		r = zor.parse(s);

		writefln("zor.parse, len: %d", r.length);

		auto	listStr = "a, c, a, b, b, d, e,   moare stuff";
		auto	charList = f.seq(f.list(chRangeP('a', 'c'), chP(',')), f.optional(chP(',')));
		setString(s, listStr);
		auto	listMatch = charList.parse(s);

		writefln("listMatch.parse, len: %d", listMatch.length);

		auto	seqOrStr = "ab";
		auto	sOr = f.seqOr(chP('a'), chP('b'));
		setString(s, seqOrStr);
		auto	sOrMatch = sOr.parse(s);

		writefln("sOrMatch.parse, len: %d", sOrMatch.length);
}

void testNumbers() {
		auto	numString = "42";
		auto	s = makeScanner(numString);
		s.first = numString.ptr;
		auto	uintMatch = uintP.parse(s);

		writefln("uintP.parse, len: %d, val: %d", uintMatch.length, uintMatch.value);

		auto	negNumString = "-42";
		setString(s, negNumString);
		auto	actionInt = intP[&intMatch];
		auto	intMatch = actionInt.parse(s);

		writefln("intP.parse, len: %d, val: %d", intMatch.length, intMatch.value);

		auto	realString = "3.44532e-2";
		setString(s, realString);
		auto	realMatch = realP[&doubleMe].parse(s);

		writefln("realP.parse, len: %d, val: %f", realMatch.length, realMatch.value);

		setString(s, realString);
		void	myIntP(int i) { writefln("got int: %d", i); }
		void	myRealP(double d) { writefln("got double: %f", d); }
		auto	intAndReal = f.or(intP[&myIntP], realP[&myRealP]);
		auto	intRealMatch = intAndReal.parse(s);
		writefln("intAndReal.parse, len: %d, val: %f", intRealMatch.length, intRealMatch.value);
}

void epsAction(in char *first, in char *last) {
	writefln("epsilon action called");
}

void testDirectives() {
	auto	testStr = "ABC";
	auto	c4 = strLitP("abc");
	auto	s = makeScanner(testStr);
	auto	caselessParser = new inhibitCase!(typeof(c4))(c4);
	auto	caselessMatch = caselessParser.parse(s);

	writefln("caselessMatch.parse, len: %d", caselessMatch.length);

	auto	longestTestStr = "123.456";
	setString(s, longestTestStr);
	auto	p0 = longestD[f.or(intP, realP)];
	auto	m0 = p0.parse(s);

	writefln("longestD: len: %d", m0.length);

	setString(s, longestTestStr);
	auto	p1 = shortestD[f.or(realP, intP)];
	m0 = p1.parse(s);

	writefln("shortestD: len: %d", m0.length);

	auto	boundsStr = "120";
	auto	p2 = minLimitD(200)[intP];
	setString(s, boundsStr);
	auto	m1 = p2.parse(s);

	writefln("minLimitD: len: %d", m1.length);

	auto	p3 = maxLimitD(200)[intP];
	setString(s, boundsStr);
	m1 = p3.parse(s);

	writefln("maxLimitD: len: %d", m1.length);

	auto	p4 = limitD(130, 140)[intP];
	setString(s, boundsStr);
	m1 = p4.parse(s);

	writefln("limitD: len: %d", m1.length);

	auto	p5 =
		f.or(
			f.seq(
				f.seq(
					f.seq(intP, chP('.')),
					intP
				),
				chP('f')
			),
			epsP[&epsAction]
		);
	setString(s, longestTestStr);
	m0 = p5.parse(s);

	writefln("epsilon match: len: %d", m0.length);
}

void testEscapeString() {
	auto	esString = "\"abcdef\" moar balls";
	auto 	s = makeScanner(esString);
	auto	escapedString = confixP(chP('"'), f.star(cEscapeCharP), chP('"'))[&printMatch];
	setString(s, esString);
	auto	esR = escapedString.parse(s);

	writefln("esR.parse, len: %d, should be 8", esR.length);
}

void testDecodingParser() {
	void gotDchar(dchar ch) {
		writefln("got encoded character: %d", ch);
	}

	auto	testStr = "tagﭲWithUtfEncodedCharacter";

	auto	r0 = chRangeP('a', 'z');
	auto	r1 = chRangeP('A', 'Z');
	auto	r2 = (new chRange!(dchar)('\uf900', '\ufdcf'))[&gotDchar];

	auto	decoder = f.star(f.or(f.or(r0, r1), r2));
	auto	s = makeScanner(testStr);
	auto	r = decoder.parse(s);

	writefln("sequence.parse len: %d", r.length);
}

int main(char[][]argv) {
	testEscapeString();
	testComposites();
	testNumbers();
	testDirectives();
	testRefactoring();
	testLooping();
	testComments();
	testRule();
	testDecodingParser();
	return 0;
}

void testRefactoring() {
	auto	str = "qsk djvlqkw ejewe";
	auto	s = makeScanner(str);
	auto	p0 = chRangeP('a', 'z');
	auto	p1 = chP('q');
	auto	a2z_sansQ = f.diff(f.star(p0), p1);
	writefln("=== PARSE");
	auto	rv0 = a2z_sansQ.parse(s);

	writefln("alpha bet minus q: %d, should be 15", rv0.length);

	auto	refactor0 = refactorUnaryD[a2z_sansQ];
	s.first = str.ptr;
	writefln("=== PARSE");
	rv0 = refactor0.parse(s);

	writefln("refactored alpha bet minus q: %d, should be 7", rv0.length);

	auto	str1 = "ababa bbba bbD";
	auto	refactor1 = refactorUnaryD[f.or(f.star(chP('a')), chP('b'))];
	s.first = str1.ptr;
	writefln("=== PARSE");
	rv0 = refactor1.parse(s);

	writefln("refactor1: %d, should be 11", rv0.length);

	// okies only match ABCD if there are some spaces somewhere
	auto	str2 = "abc de";
	auto	p2 = f.diff(chSeqP("abc")[&printMatch], strLitP("abc"));
	s.first = str2.ptr;
	writefln("=== PARSE");
	rv0 = p2.parse(s);

	writefln("p2 won't match, but will fire printMatch, match len: %d", rv0.length);

	// ok refactor it, we don't want printMatch called unless the diff succeeds
	auto	p3 = refactorActionD[p2];
	s.first = str.ptr;
	writefln("=== PARSE");
	rv0 = p3.parse(s);

	writefln("p2 won't match, and no action gets called, match len: %d", rv0.length);

	// okies only match ABCD if there are some spaces somewhere
	auto	p4 = f.diff(chSeqP("abc"), strLitP("abc"))[&printMatch];
	s.first = str2.ptr;
	writefln("=== PARSE");
	rv0 = p4.parse(s);

	writefln("p4 won't match, and won't fire printMatch, match len: %d", rv0.length);

	// refactor so action is attached to both chSeqP & the strLitP
	auto	p5 = attachActionD[p4];
	s.first = str2.ptr;
	writefln("=== PARSE");
	rv0 = p5.parse(s);

	writefln("p5 won't match, and will fire printMatch twice, match len: %d", rv0.length);
}

void testLooping() {
	auto	str = "aaaa aa a bbbbbbbb";
	auto	s = makeScanner(str);
	auto	p = f.seq(repeatP(5, moreT())[chP('a')], chP('b'));
	auto	m = p.parse(s);

	writefln("loop test: %d", m.length);
}

void testComments() {
	auto	str = "/* comment one*/ lkjdsfad";
	auto	s = makeScanner(str);
	auto	p = commentP("/*", "*/");
	auto	m = p.parse(s);

	writefln("comment test: %d", m.length);
}

void testRule() {
	auto	str = "312302145";
	auto	s = makeScanner(str);
	auto	r = new rule!(typeof(s));
	r = f.seq(chP('a'), chP('b'));
	auto	match = r.parse(s);

	writefln("r match: %d", match.length);

	auto	r1 = new rule!(typeof(s));
	s.first = str.ptr;
	r1 = intP[&intMatch];
	match = r1.parse(s);

	writefln("r match: %d", match.length);
}
