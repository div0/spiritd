/**
	spiritd example - s.d.hammett
	example of a parser which parses a nested tree style syntax.
*/

import std.stdio;

import spiritd.factory;
import spiritd.grammar;
import spiritd.parse;
import spiritd.primitives;
import spiritd.match;
import spiritd.nil;
import spiritd.numerics;
import spiritd.rule;
import spiritd.util;
import spiritd.composite.directives;
import spiritd.utility.confix;
import spiritd.utility.escapeChar;

class prefsGrammar : grammar!(prefsGrammar) {

	struct definition(scannerT) {
		alias	rule!(scannerT)		rT;

		rT	start(prefsGrammar outer) {
			assert(outer !is null, "passed null reference as containing grammar!");
			_outer = outer;
			return create;
		}
	private:
		prefsGrammar	_outer;

		rT	creatBoolParser() {
			rT	boolVal = rT.create(
					or(strLitP("true"), strLitP("false")));
			return boolVal;
		}

		rT	createFieldName() {
			rT	fieldName = rT.create(
					lexemeD[
						seq(
							or(alphaP, chP('_')),
							star(or(alnumP, chP('_')))
						)
					]);
			return fieldName;
		}

		rT	createField(rT fieldName, rT values) {
			rT	field = rT.create(
					seq(
						seq(fieldName[&_outer.gotFieldName], chP(':')),
						values
					));
			return field;
		}

		rT	create() {
			rT		boolVal		= creatBoolParser();

			// we can't put rules inside parsers which change the scanner type at the mo,
			// so we have to create the parser where we reference it
			auto	stringVal = lexemeD[confixP('"', star(cEscapeCharP)[&_outer.gotEscapedString], '"')];

			rT	arrayValues = rT.create(
				or(	
					lookAhead(
						seq(
							chP('[')[&_outer.gotIntArray],
							seq(
								list(intP[&_outer.pushIntArray], chP(',')),
								chP(']')[&_outer.gotEndArray]
							)
						),
						seq(
							chP('[')[&_outer.gotRealArray],
							seq(
								list(realP[&_outer.pushRealArray], chP(',')),
								chP(']')[&_outer.gotEndArray]
							)
						),
						function uint (Match!(nilT)[] matches) {
							foreach(uint indx, ref Match!(nilT) m; matches)
								if(m.match)
									return indx;
							return -1;
						}
					),
					seq(
						chP('[')[&_outer.gotStringArray],
						seq(
							list(stringVal[&_outer.pushStringArray], chP(',')),
							chP(']')[&_outer.gotEndArray]
						)
					)
				));

			rT	parseInt	= rT.create(intP[&_outer.gotInt]);
			rT	parseBool	= rT.create(boolVal[&_outer.gotBool]);
			rT	values		= rT.create(or(or(or(parseInt, parseBool), stringVal), arrayValues));
			rT	fieldName	= createFieldName();
			rT	field		= createField(fieldName, values);
			rT	blockStart	= rT.create(seq(stringVal[&_outer.gotBlockName], chP('{')[&_outer.gotStartBlock]));

			rT	g = rT.create(
					seq(
						blockStart,
						positive(
							or(
								chP('}')[&_outer.gotEndBlock],
								or(field, blockStart)
							)
						)
					));

			return g;
		}
	}
private:
	alias	iteratorType!(string)._resultT	_iteratorT;
	alias	char _valueT;

	void	gotBlockName(_iteratorT begin, _iteratorT end) {
		writefln("got block name: %s", begin[0 .. end - begin]);
	}

	void	gotStartBlock(_valueT) {
		writefln("got start block");
	}

	void	gotEndBlock(_valueT) {
		writefln("got block end");
	}

	void	gotFieldName(_iteratorT begin, _iteratorT end) {
		writefln("got field name: %s", begin[0 .. end - begin]);
	}

	void	gotInt(int i) {
		writefln("got int: %d", i);
	}

	void	gotBool(_iteratorT begin, _iteratorT end) {
		writefln("got bool: %s", begin[0 .. end - begin]);
	}

	void	gotEscapedString(_iteratorT begin, _iteratorT end) {
		writefln("got escaped string: %s", begin[0 .. end - begin]);
	}

	void	gotArrayString(_iteratorT begin, _iteratorT end) {
		auto str = begin[1 .. end - begin - 1];
	}

	void	gotIntArray(_valueT) {
		writefln("start of int array");
	}

	void	pushIntArray(int i) {
		writefln("array int value: %d", i);
	}

	void	gotRealArray(_valueT) {
		writefln("start of real array");
	}

	void	pushRealArray(double d) {
		writefln("array double value: %f", d);
	}

	void	gotStringArray(_valueT) {
		writefln("start of string array");
	}

	void	pushStringArray(_iteratorT begin, _iteratorT end)	{
		auto str = begin[1 .. end - begin - 1];
		writefln("array str value: %s", str);
	}

	void	gotEndArray(_valueT) {
		writefln("end of array");
	}
}

void main() {
	string	prefs =
`"user" {
	debugging: false
	history: 42
# a comment
	"mru" {
		_0: "c:\development\workspace\spiritd\test0.d"	# another comment
		_1: "c:\development\workspace\spiritd\spiritd\rule.d"
		_2: "c:\development\workspace\spiritd\spiritd\impl\rule.d"
	}
}
# note the use of lookAhead parser to distinguish between the two array types
# this saves mucking about when writing our symantic actions; we don't need to
# worry about backtracking
anIntArray: [ 0, 1, 2, 3 ]
aFloatArray: [ 0, 1, 2, 3.3 ]
`;
	auto	p = new prefsGrammar;
	auto	m = spiritd.parse.parse(prefs, p, or(spaceP, commentP('#')));
	writefln("matched %d characters", m.length);
}
