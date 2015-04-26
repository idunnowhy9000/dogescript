{
	var maybeOP = {
		"type": "UnaryExpression",
		"operator": "!",
		"argument": {
			"type": "UnaryExpression",
			"operator": "+",
			"argument": {
				"type": "CallExpression",
				"callee": {
					"type": "MemberExpression",
					"computed": false,
					"object": {
						"type": "Identifier",
						"name": "Math"
					},
					"property": {
						"type": "Identifier",
						"name": "random"
					}
				},
				"arguments": []
			},
			"prefix": true
		},
		"prefix": true
	};
		
	function buildList(first, rest, index) {
		return [first].concat(extractList(rest, index));
	}

	function optionalList(value) {
		return value !== null ? value : [];
	}
	
	function optionalStr(value) {
		return value !== null ? value : "";
	}
	
	function extractList(list, index) {
		var result = new Array(list.length), i;

		for (i = 0; i < list.length; i++) {
		  result[i] = list[i][index];
		}

		return result;
	}
	
	function extractOptional(optional, index) {
		return optional ? optional[index] : null;
	}
	
	function extractOptionalList(optional, index) {
		return Array.isArray(optional) ? optional[index]: [];
	}
	
	function filledArray(count, value) {
		var result = new Array(count), i;

		for (i = 0; i < count; i++) {
			result[i] = value;
		}

		return result;
	}
	
	function moduleName(str) {
		var mod = str, m = /(.*)\.[^.]+$/.exec(str);
		if (m !== null) {
			mod = m[1];
		}
		mod = mod.replace('-', '_');
		return mod;
	}
	
	function parseDecLiteral(str) {
		return parseFloat(str.replace(/very/i, "e"));
	}
	
	function buildTree(first, rest, builder) {
		var result = first, i;
		for (i = 0; i < rest.length; i++) {
			result = builder(result, rest[i]);
		}
		return result;
	}
	
	function buildBinaryExpression(first, rest) {
		return buildTree(first, rest, function(result, element) {
			return {
				type: "BinaryExpression",
				operator: element[1],
				left: result,
				right: element[3]
			};
		});
	}
	
	function buildLogicalExpression(first, rest) {
		return buildTree(first, rest, function(result, element) {
			return {
				type: "LogicalExpression",
				operator: element[1],
				left: result,
				right: element[3]
			};
		});
	}
}

start = __ program:Program __ {return program;}

/** 1. Lexical Grammar */

/* End of statement */
EOS "end of statement"
	= EOF
	/ ";"
	/ LineTerminator

/* EOF */
EOF "end of file"
	= !.

/* Source Character */
SourceCharacter "any character"
	= .

/* SourceCharacter without line terminator */
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
LineTerminator "end of line" = [\n\r\u2028\u2029]

/* Line Terminator Sequence */
LineTerminatorSequence "end of line sequence"
	= "\n"
	/ "\r\n"
	/ "\r"
	/ "\u2028"
	/ "\u2029"

/* Comment */
Comment "comment"
	= SingleLineComment
	/ MultiLineComment

/* Multi-line Comment */
MultiLineComment
	= "quiet" (!"loud" SourceCharacter)* "loud"

MultiLineCommentNoLineTerminator
	= "quiet" (!("loud" / LineTerminator) SourceCharacter)* "loud"

/* Single-line Comment */
SingleLineComment
	= "shh" (!LineTerminator SourceCharacter)*

NEWLINE "newline" = [\n\r]

/** Skipped */
__
	= (WhiteSpace / LineTerminatorSequence / Comment)*

_
	= (WhiteSpace / MultiLineCommentNoLineTerminator)*

/* Tokens */
VeryToken       = "very"          !IdentifierPart
AlwaysToken     = "always"        !IdentifierPart
IsToken         = "is"            !IdentifierPart
AsToken         = "as"            !IdentifierPart
WowToken        = "wow"           !IdentifierPart
TrainedToken    = "trained"       !IdentifierPart
SoToken         = "so"            !IdentifierPart
AsToken         = "as"            !IdentifierPart
OutToken        = "out"           !IdentifierPart
DeboogerToken   = "debooger"      !IdentifierPart
BarkToken       = "bark"          !IdentifierPart
ThisToken       = "this"          !IdentifierPart
SuchToken       = "such"          !IdentifierPart
PlzToken        = "plz"           !IdentifierPart
DoseToken       = "dose"          !IdentifierPart
RlyToken        = "rly"           !IdentifierPart
ButToken        = "but"           !IdentifierPart
ManyToken       = "many"          !IdentifierPart
MuchToken       = "much"          !IdentifierPart
NotrlyToken     = "notrly"        !IdentifierPart
DogeofToken     = "dogeof"        !IdentifierPart
MaybeToken      = "maybe"         !IdentifierPart
YesToken        = "yes"           !IdentifierPart
NoToken         = "no"            !IdentifierPart
EmptyToken      = "empty"         !IdentifierPart
RetrieveToken   = "retrieve"      !IdentifierPart
TypeofToken     = "typeof"        !IdentifierPart
TrueToken       = "true"          !IdentifierPart
FalseToken      = "false"         !IdentifierPart
NullToken       = "null"          !IdentifierPart
VoidToken       = "void"          !IdentifierPart
DeleteToken     = "delete"        !IdentifierPart
CatchToken      = "catch"         !IdentifierPart
NewToken        = "new"           !IdentifierPart
NotToken        = "not"           !IdentifierPart
SmallerToken    = "smaller"       !IdentifierPart
SmallerishToken = "smallerish"    !IdentifierPart
BiggerToken     = "bigger"        !IdentifierPart
BiggerishToken  = "biggerish"     !IdentifierPart
ShibeofToken    = "shibeof"       !IdentifierPart
InstanceofToken = "instanceof"    !IdentifierPart
WithToken       = "with"          !IdentifierPart
MoreToken       = "more"          !IdentifierPart
LessToken       = "less"          !IdentifierPart
LotsToken       = "lots"          !IdentifierPart
FewToken        = "few"           !IdentifierPart
InToken         = "in"            !IdentifierPart
NextToken       = "next"          !IdentifierPart
ThrowToken      = "throw"         !IdentifierPart
TryToken        = "try"           !IdentifierPart
CatchToken      = "catch"         !IdentifierPart
RetrieveToken   = "retrieve"      !IdentifierPart
AndToken        = "and"           !IdentifierPart
OrToken         = "or"            !IdentifierPart
AlsoToken       = "also"          !IdentifierPart

/** 2. Grammar Rules */

/* Program */
Program
	= body:SourceElements?
	{
		return {
			"type": "Program",
			"body": optionalList(body)
		};
	}

/* Source Elements */
SourceElements
	= first:SourceElement rest:(__ SourceElement)* {return buildList(first, rest, 1);}

/* Source Element */
SourceElement
	= Statement
	/ FunctionDeclaration

/** 2.1 Statements */
/* Statement */
Statement
	= AssignmentStatement
	/ VariableStatement
	/ ExpressionStatement
	/ WowStatement
	/ TrainedStatement
	/ ImportStatement
	/ ExportStatement
	/ DeboogerStatement
	/ BarkStatement
	/ ThrowStatement
	/ IfStatement
	/ WhileStatement
	/ ForStatement
	/ TryStatement

/* Variable declarations */
VariableStatement
	= type:VariableDeclarationType __ decl:VariableDeclarationList EOS
	{
		return {
			"type": "VariableDeclaration",
			"declarations": decl,
			"kind": type
		};
	}

VariableDeclarationType
	= VeryToken {return "var"} / AlwaysToken {return "const"}

VariableDeclarationList
	= first:VariableDeclaration rest:(__ "," __ VariableDeclaration)*
	{ return buildList(first, rest, 3); }

VariableDeclaration
	= iden:Identifier expr:(__ VariableDeclarationOperator __ Expression)?
	{
		return {
			type: "VariableDeclarator",
			id: iden,
			init: extractOptional(expr, 3)
		};
	}

VariableDeclarationOperator
	= IsToken / AsToken / ("=" !"=")

/* AssignmentStatement */
AssignmentStatement
	=  left:LeftHandSideExpression __ (("=" !"=") / IsToken) __ right:Expression EOS
	{
		return {
            "type": "ExpressionStatement",
            "expression": {
                "type": "AssignmentExpression",
                "operator": "=",
                "left": left,
                "right": right
            }
        };
	}

/* Wow: ends block */
WowStatement
	= WowToken _ v:Expression EOS
	{
		return {
			"type": "ReturnStatement",
			"argument": v
		}
	}

EmptyWowStatement = WowToken

/* ExpressionStatement */
ExpressionStatement
	= expr:Expression EOS
	{
		return {
			"type": "ExpressionStatement",
			"expression": expr
		}
	}

/* Trained Statement */
TrainedStatement
	= TrainedToken EOS
	{
		return {
			"type": "ExpressionStatement",
			"expression": {
				"type": "Literal",
				"value": "use strict"
			}
		}
	}

/* ImportStatement */
ImportStatement
	= SoToken __ str:(Identifier / StringLiteral) as:(__ AsToken __ (Identifier / StringLiteral))? EOS
	{
		var _as = optionalList(extractOptional(as, 3));
		var asName;
		
		if ('name' in _as) asName = _as['name'];
		else if ('value' in _as) asName = _as['value'];
		else if ('name' in str) asName = str['name'];
		else if ('value' in str) asName = str['value'];
		
		return {
			"type": "VariableDeclaration",
			"declarations": [
				{
					"type": "VariableDeclarator",
					"id": {
						"type": "Identifier",
						"name": moduleName(asName)
					},
					"init": {
						"type": "CallExpression",
						"callee": {
							"type": "Identifier",
							"name": "require"
						},
						"arguments": [
							{
								"type": "Literal",
								"value": str['name'] || str['value']
							}
						]
					}
				}
			],
			"kind": "var"
		}
	}

/* Export Statement */
ExportStatement
	= OutToken __ expr:Expression EOS
	{
		return {
			"type": "ExpressionStatement",
			"expression": {
				"type": "AssignmentExpression",
				"operator": "=",
				"left": {
					"type": "MemberExpression",
					"computed": false,
					"object": {
						"type": "Identifier",
						"name": "module"
					},
					"property": {
						"type": "Identifier",
						"name": "exports"
					}
				},
				"right": expr
			}
		};
	}

/* DeboogerStatement */
DeboogerStatement
	= DeboogerToken EOS
	{
		return {
			"type": "DebuggerStatement"
		}
	}

/* Bark Statement */
BarkStatement
	= BarkToken EOS
	{
		return {
			"type": "BreakStatement"
		}
	}

/** 2.1.1 Blocks */
Block
	= __ left:SourceElements? __
	{
		return {
			"type": "BlockStatement",
			"body": optionalList(left)
		};
	}

/** 2.2 Values */
Value
	= thisValue
	/ Identifier
	/ Literal

Literal
	= NullLiteral
	/ BooleanLiteral
	/ NumericLiteral
	/ StringLiteral
	/ ArrayLiteral
	/ ObjectLiteral
	/ DSONLiteral

thisValue
	= ThisToken
	{
		return {
			"type": "ThisExpression"
		};
	}

/* Identifiers */
Identifier
	= !ReservedWord name:IdentifierName {return name;}

IdentifierName "identifier"
	= first:IdentifierStart rest:IdentifierPart*
	{		
		return {
			"type": "Identifier",
			"name": first + rest.join("")
		};
	}

IdentifierStart
	= [a-zA-Z] / "$" / "_"

IdentifierPart
	= IdentifierStart
	/ [0-9]

/* Reserved Words (keywords) */
ReservedWord
	= VeryToken
	/ AlwaysToken
	/ IsToken
	/ AsToken
	/ WowToken
	/ TrainedToken
	/ SoToken
	/ OutToken
	/ DeboogerStatement
	/ BarkToken
	/ ThisToken
	/ SuchToken
	/ PlzToken
	/ DoseToken
	/ RlyToken
	/ ButToken
	/ ManyToken
	/ MuchToken
	/ NotrlyToken
	/ DogeofToken
	/ MaybeToken
	/ YesToken
	/ NotToken
	/ EmptyToken
	/ TypeofToken
	/ TrueToken
	/ FalseToken
	/ NullToken
	/ VoidToken
	/ DeleteToken
	/ CatchToken
	/ NewToken
	/ SmallerToken
	/ SmallerishToken
	/ BiggerToken
	/ BiggerishToken
	/ ShibeofToken
	/ InstanceofToken
	/ WithToken
	/ MoreToken
	/ LessToken
	/ LotsToken
	/ FewToken
	/ NextToken
	/ ThrowToken
	/ TryToken
	/ RetrieveToken
	/ AndToken
	/ OrToken
	/ AlsoToken

/** Literals */
/* Null Literals */
NullLiteral
	= (NullToken / EmptyToken) { return { type: "Literal", value: null }; }

/* Boolean Literals */
BooleanLiteral
	= (TrueToken / YesToken) { return { type: "Literal", value: true }; }
	/ (FalseToken / NoToken) { return { type: "Literal", value: false }; }
	/ MaybeToken { return maybeOP; }

/* Numeric Literals */
NumericLiteral
	= literal:DecimalLiteral !(IdentifierStart / DecimalDigit) {return literal;}

/* Decimal Literals */
DecimalLiteral
	= DecimalIntegerLiteral "." DecimalDigit* ExponentPart?
	{ return { "type": "Literal", "value": parseDecLiteral(text()) }; }
	/ "." DecimalDigit+ ExponentPart?
	{ return { "type": "Literal", "value": parseDecLiteral(text()) }; }
	/ DecimalIntegerLiteral+ ExponentPart?
	{ return { "type": "Literal", "value": parseDecLiteral(text()) }; }

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

/* String Literals */
StringLiteral "string"
	= '"' chars:DoubleStringCharacter* '"' {
		return { type: "Literal", value: chars.join("") };
	}
	/ "'" chars:SingleStringCharacter* "'" {
		return { type: "Literal", value: chars.join("") };
	}

DoubleStringCharacter
	= !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
	/ "\\" sequence:EscapeSequence { return sequence; }
	/ LineContinuation

SingleStringCharacter
	= !("'" / "\\" / LineTerminator) SourceCharacter { return text(); }
	/ "\\" sequence:EscapeSequence { return sequence; }
	/ LineContinuation

LineContinuation
	= "\\" LineTerminatorSequence { return ""; }

EscapeSequence
	= CharacterEscapeSequence
	/ "0" !DecimalDigit { return "\0"; }

CharacterEscapeSequence
	= SingleEscapeCharacter

SingleEscapeCharacter
	= "'"
	/ '"'
	/ "\\"
	/ "b"  { return "\b"; }
	/ "f"  { return "\f"; }
	/ "n"  { return "\n"; }
	/ "r"  { return "\r"; }
	/ "t"  { return "\t"; }
	/ "v"  { return "\v"; }

/* Object Literals */
ObjectLiteral
	= "{" __ "}" {return { "type": "ObjectExpression", "properties": [] };}
	/ "{" __ obj:ObjectMembers __ "}" {return { "type": "ObjectExpression", "properties": obj };}

ObjectMembers
	= first:ObjectPair rest:(__ "," __ ObjectPair)*
	{
		return buildList(first, rest, 3);
	}

ObjectPair
	= key:ObjectPropertyName __ ":" __ value:Expression
	{
		return {
			"key": key,
			"value": value,
			"kind": "init"
		}
	}

ObjectPropertyName
	= IdentifierName
	/ StringLiteral
	/ NumericLiteral

/** DSON Literals */
DSONLiteral
	= "{{" __ "}}" { return { "type": "ObjectExpression", "properties": [] }; }
	/ "{{" __ obj:DSONObject __ "}}" { return { "type": "ObjectExpression", "properties": obj }; }

DSONObject
	= SuchToken __ member:DSONMembers? __ WowToken { return optionalList(member); }

DSONMembers
	= first:DSONPair rest:(__ DSONMemberSeparator __ DSONPair)* { return buildList(first, rest, 3); }

DSONMemberSeparator
	= "," / "." / "!" / "?"

DSONPair
	= key:ObjectPropertyName __ IsToken __ value:DSONValue
	{
		return {
			"key": key,
			"value": value,
			"kind": "init"
		}
	}

DSONArray
	= SoToken __ elements:DSONArrayElements? __ ManyToken
	{
		return {
			"type": "ArrayExpression",
			"elements": elements
		}
	}

DSONArrayElements
	= first:DSONValue rest:(__ DSONArraySeperator __ DSONValue)*
	{
		return buildList(first, rest, 3);
	}

DSONArraySeperator
	= AndToken / AlsoToken

DSONValue
	= Identifier
	/ StringLiteral
	/ NumericLiteral
	/ DSONObject
	/ DSONArray
	/ YesToken {return {"type": "Identifier", "name": true}}
	/ NoToken {return {"type": "Identifier", "name": false}}
	/ EmptyToken {return {"type": "Identifier", "name": null}}

/** Array Literals */
ArrayLiteral
	= "[" __ elision:(Elision __)? "]" {
		return {
			type: "ArrayExpression",
			elements: optionalList(extractOptional(elision, 0))
		};
	}
	/ "[" __ elements:ElementList __ "]" {
		return {
			type: "ArrayExpression",
			elements: elements
		};
	}
	/ "[" __ elements:ElementList __ "," __ elision:(Elision __)? "]" {
		return {
			type: "ArrayExpression",
			elements: elements.concat(optionalList(extractOptional(elision, 0)))
		};
	}

ElementList
	= first:(
		elision:(Elision __)? element:Expression {
			return optionalList(extractOptional(elision, 0)).concat(element);
		}
	)
	rest:(
		__ "," __ elision:(Elision __)? element:Expression {
			return optionalList(extractOptional(elision, 0)).concat(element);
		}
	)*
	{ return Array.prototype.concat.apply(first, rest); }

Elision
	= "," commas:(__ ",")* { return filledArray(commas.length + 1, null); }

/** 2.3 Expression */
/* Expressions */
Expression
	= AssignmentExpression

Primary
	= Value
	/ "(" __ left:Expression __ ")" {return left;}

/* "Algebra" expressions */
AdditiveExpression
	= first:MultiplicativeExpression rest:(__ AdditiveOperator __ MultiplicativeExpression)*
	{ return buildBinaryExpression(first, rest); }

AdditiveOperator
	= "+" / "-"

MultiplicativeExpression
	= first:UnaryExpression rest:(__ MultiplicativeOperator __ UnaryExpression)*
	{ return buildBinaryExpression(first, rest); }

MultiplicativeOperator
	= "*" / "/" / "%"

/* Logical expressions */
LogicalORExpression
	= first:LogicalANDExpression rest:(__ LogicalOROperator __ LogicalANDExpression)*
	{ return buildLogicalExpression(first, rest); }

LogicalOROperator
	= (OrToken / "||") {return "||"}

LogicalANDExpression
	= first:ComparisonExpression rest:(__ LogicalANDOperator __ ComparisonExpression)*
	{ return buildLogicalExpression(first, rest); }

LogicalANDOperator
	= (AndToken / "&&") {return "&&"}

LeftHandSideExpression
	= CallExpression / NewExpression

/* Unary expressions */
PostfixExpression
	= argument:LeftHandSideExpression _ operator:PostfixOperator
	{
		return {
			"type": "UpdateExpression",
			"operator": operator,
			"argument": argument,
			"prefix": false
		};
	}
	/ LeftHandSideExpression

PostfixOperator
	= "++" / "--"

UnaryExpression
	= PostfixExpression
	/ op:UnaryOperator _ argument:UnaryExpression
	{
		return {
			"type": "UnaryExpression",
			"operator": op,
			"argument": argument,
			"prefix": true
		};
	}

UnaryOperator
	= (DogeofToken / TypeofToken) {return "typeof"}
	/ (NotrlyToken / "!") {return "!"}
	/ $DeleteToken / $VoidToken / "~" / "++" / "--" / "+" / "-"

/* Comparison */
ComparisonExpression
	= first:RelationalExpression rest:(__ ComparisonOperator __ RelationalExpression)*
	{ return buildBinaryExpression(first, rest); }

ComparisonOperator
	= (NotToken / "!==") {return "!=="} / (IsToken / "===") {return "==="}
	/ "==" / "!="

/* Relationals */
RelationalExpression
	= first:AdditiveExpression rest:(__ RelationalOperator __ AdditiveExpression)*
	{ return buildBinaryExpression(first, rest); }
	
RelationalOperator
	= (SmallerishToken / "<=") {return "<="}
	/ (SmallerToken / "<") {return "<"}
	/ (BiggerishToken / ">=") {return ">="}
	/ (BiggerToken / ">") {return ">"}
	/ (ShibeofToken / InstanceofToken) {return "instanceof"}

/* Function Call Expressions */
CallExpression
	= PlzToken __ iden:MemberExpression args:(__ WithToken __ FunctionArguments)?
	{
		return {
			"type": "CallExpression",
			"callee": iden,
			"arguments": optionalList(extractOptional(args, 3))
		}
	}
	/* support old "console dose loge" notation */
	/ iden:MemberExpression __ WithToken __ args:FunctionArguments
	{ return { "type": "CallExpression", "callee": iden, "arguments": args }; }
	
/* New Expressions */
NewExpression
	= MemberExpression
	/ NewToken __ iden:MemberExpression args:(__ WithToken __ FunctionArguments)?
	{
		return {
			"type": "NewExpression",
			"callee": iden,
			"arguments": extractOptionalList(args, 3)
		}
	}

/* AssignmentExpression */
AssignmentExpression
	= left:LeftHandSideExpression __ (("=" !"=") / AsToken) __ right:Expression
	{
		return {
			"type": "AssignmentExpression",
			"operator": "=",
			"left": left,
			"right": right
		};
	}
	/ left:LeftHandSideExpression __ op:AssignmentOperator __ right:AssignmentExpression
	{
		return {
			"type": "AssignmentExpression",
			"operator": op,
			"left": left,
			"right": right
		};
	}
	/ ConditionalExpression

AssignmentOperator
	= (AsToken / "=") {return "="}
	/ (MoreToken / "+=") {return "+="}
	/ (LessToken / "-=") {return "-="}
	/ (LotsToken / "*=") {return "*="}
	/ (FewToken / "/=") {return "/="}

ConditionalExpression
	= test:LogicalORExpression __
	"?" __ consequent:AssignmentExpression __
	":" __ alternate:AssignmentExpression
	{ return { "type": "ConditionalExpression", "test": test, "consequent": consequent, "alternate": alternate }; }
	/ test:LogicalORExpression __
	RlyToken __ consequent:AssignmentExpression __
	ButToken __ alternate:AssignmentExpression
	{ return { "type": "ConditionalExpression", "test": test, "consequent": consequent, "alternate": alternate }; }
	/ LogicalORExpression

MemberExpression
	= first:(
		Primary
		/ FunctionExpression
		/ NewToken __ iden:MemberExpression args:(__ WithToken __ FunctionArguments)?
		{
			return {
				"type": "NewExpression",
				"callee": iden,
				"arguments": optionalList(extractOptional(args, 3))
			}
		}
	)
	rest: (
		__ "[" __ property:Expression __ "]" {
			return {"property": property, "computed": true}
		}
		/ __ ("." / "dose") __ property:IdentifierName {
			return {"property": property, "computed": false}
		}
	)*
	{
		return buildTree(first, rest, function(result, element) {
			return {
				type: "MemberExpression",
				object: result,
				property: element.property,
				computed: element.computed
			};
		});
	}

/** 2.4 Function declarations */
FunctionDeclaration
	= SuchToken _ iden:Identifier args:(_ MuchToken _ FormalParameterList)? NEWLINE block:Block EmptyWowStatement
	{
		return {
			"type": "FunctionDeclaration",
			"id": iden,
			"params": extractOptionalList(args, 3),
			"body": block,
			
			"generator": false,
			"expression": false
		}
	}

/* FunctionExpression: buggy but works? */
FunctionExpression	
	= MuchToken args:(_ FormalParameterList)? NEWLINE body:Block EmptyWowStatement
	{
		return {
			"type": "FunctionExpression",
			"id": null,
			"params": extractOptionalList(args, 1),
			"body": body
		};
	}

FunctionArguments "arguments"
	= first:Expression rest:(__ "," __ Expression)*
	{
		return buildList(first, rest, 3);
	}

FormalParameterList
	= first:Identifier rest:(__ "," __ Identifier)*
	{
		return buildList(first, rest, 3);
	}

/** 2.5 If Statements */
IfStatement
	= RlyToken _ test:Expression NEWLINE block:Block _else:(EmptyWowStatement {return null;} / ElseStatement)
	{
		return {
			"type": "IfStatement",
			"test": test,
			"consequent": block,
			"alternate": _else 
		};
	}

/** 2.5.1 Else Statements */
ElseStatement
	= ButToken _ block:IfStatement {return block;}
	/ ButToken NEWLINE block:Block EmptyWowStatement {return block;}

/** 2.6 While Statements */
WhileStatement
	= ManyToken _ test:Expression NEWLINE block:Block EmptyWowStatement
	{
		return {
			"type": "WhileStatement",
			"test": test,
			"body": block
		};
	}

/** 2.7 For Statements */
ForStatement
	= MuchToken _
	init:(Expression _)? ForNext _
	test:(Expression _)? ForNext _
	update:Expression? NEWLINE
	body:Block
	EmptyWowStatement
	{
		return {
			"type": "ForStatement",
			"init": extractOptional(init, 0),
			"test": extractOptional(test, 0),
			"update": update || null,
			"body": body
		};
	}
	/ MuchToken _
	VeryToken _ declarations:VariableDeclarationList _ ForNext _
	test:(Expression _)? ForNext _
	update:Expression? NEWLINE
	body:Block
	EmptyWowStatement
	{
		return {
			"type": "ForStatement",
			"init": {
				"type": "VariableDeclaration",
				"declarations": declarations,
				"kind": "var"
			},
			"test": extractOptional(test, 0),
			"update": update || null,
			"body": body
		};
	}
	/ MuchToken _
	left:LeftHandSideExpression _
	InToken _
	right:Expression NEWLINE
	body:Block
	EmptyWowStatement
	{
		return {
			"type": "ForInStatement",
			"left": left,
			"right": right,
			"body": body
		};
	}
	/ MuchToken _
	VeryToken _ declarations:VariableDeclarationList _
	InToken _
	right:Expression NEWLINE
	body:Block
	EmptyWowStatement
	{
		return {
			"type": "ForInStatement",
			"left": {
				"type": "VariableDeclaration",
				"declarations": declarations,
				"kind": "var"
			},
			"right": right,
			"body": body
		};
	}

ForNext = NextToken / ';'

/** 2.8 Try-Catch-Finally Statements */
TryStatement
	= TryToken NEWLINE block:Block handler:Catch finalizer:Finally EmptyWowStatement
	{
		return {
			"type": "TryStatement",
			"block": block,
			"handler": handler,
			"finalizer": finalizer
		};
	}
	/ TryToken NEWLINE block:Block handler:Catch EmptyWowStatement
	{
		return {
			"type": "TryStatement",
			"block": block,
			"handler": handler,
			"finalizer": null
		};
	}
	/ TryToken NEWLINE block:Block finalizer:Finally EmptyWowStatement
	{
		return {
			"type": "TryStatement",
			"block": block,
			"handler": null,
			"finalizer": finalizer
		};
	}

Catch
	= CatchToken _ param:Identifier NEWLINE body:Block
	{
		return {
			"type": "CatchClause",
			"param": param,
			"body": body
		};
	}

Finally
	= RetrieveToken NEWLINE body:Block
	{
		return body;
	}

/** 2.9 Throw Statement */
ThrowStatement
	= ThrowToken _ left:Expression EOS
	{
		return {
			"type": "ThrowStatement",
			"argument": left
		};
	}