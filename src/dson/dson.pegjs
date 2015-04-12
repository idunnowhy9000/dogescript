{
	function buildList(first, rest, index) {
		return [first].concat(extractList(rest, index));
	}
	
	function parseDecLiteral(str) {
		return parseFloat(str.replace(/(very|VERY)/, "e"));
	}
}

start = _ object:DSONLiteral _ {return object;}

/** 1. Lexical Grammar */
SourceChar = .
SourceChars = SourceChar*

SourceCharacterNoTerm = !LineTerminator char:. {return char;}

SourceCharacterNoQuote1 = !"'" char:SourceCharacterNoTerm {return char;}
SourceCharacterNoQuote2 = !'"' char:SourceCharacterNoTerm {return char;}

/* Whitespace */
WhiteSpace "whitespace"
	= "\t"
	/ "\v"
	/ "\f"
	/ " "
	/ "\u00A0"
	/ "\uFEFF"
	/ [\u0020\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]

/* Line Terminator */
LineTerminator "line terminator" = [\n\r\u2028\u2029]

/* Skipped */
_
	= (WhiteSpace / LineTerminator)*

/** 2. Language Grammar */
DSONLiteral
	= _ obj:DSONObject _ { return obj; }

DSONObject
	= "such" _ member:DSONMembers? _ "wow" { return member == null ? {} : member; }

DSONMembers
	= first:DSONPair rest:(_ DSONMemberSeparator _ DSONPair)*
	{
		var result = {}, i;
		result[first[0]] = first[1];
		for (i = 0; i < rest.length; i++) {
			result[rest[i][0]] = rest[i][1];
		}
		return result;
	}

DSONMemberSeparator
	= "," / "." / "!" / "?"

DSONPair
	= key:StringLiteral _ "is" _ value:DSONValue
	{
		return [key, value];
	}

DSONArray
	= "so" _ elements:DSONArrayElements? _ "many"
	{
		return elements;
	}

DSONArrayElements
	= first:DSONValue rest:(_ DSONArraySeperator _ DSONValue)*
	{
		return buildList(first, rest, 3);
	}

DSONArraySeperator
	= "and" / "also"

DSONValue
	= StringLiteral
	/ NumericLiteral
	/ DSONObject
	/ DSONArray
	/ "yes" {return true;}
	/ "no" {return false;}
	/ "empty" {return null;}

StringLiteral
	= "'" c:SourceCharacterNoQuote1* "'"
	{return c.join("");}
	/ '"' c:SourceCharacterNoQuote2* '"'
	{return c.join("");}

NumericLiteral
	= literal:DecimalLiteral {return literal;}

/* Decimal Literals */
DecimalLiteral
	= DecimalIntegerLiteral "." DecimalDigit* ExponentPart? { return parseDecLiteral(text()); }
	/ "." DecimalDigit+ ExponentPart? { return parseDecLiteral(text()); }
	/ DecimalIntegerLiteral+ ExponentPart? { return parseDecLiteral(text()); }

DecimalIntegerLiteral
	= "0"
	/ NonZeroDigit DecimalDigit*

DecimalDigit
	= [0-9]

NonZeroDigit
	= [1-9]

/* ExponentPart */
ExponentPart
	= ExponentIndicator SignedInteger

ExponentIndicator
	= "e"i / "very"i

SignedInteger
	= [+-]? DecimalDigit+
