{
	var keyMapping = {
		"is": "===",
		"not": "!==",
		"and": "&&",
		"or": "||",
		"smaller": "<",
		"bigger": ">",
		"smallerish": "<=",
		"biggerish": ">=",
		"notrly": "!",
		"dogeof": "typeof",
		"shibeof": "instanceof",
		"as": '=',
		"more": "+=",
		"less": "-=",
		"lots": "*=",
		"few": "/=",
	};
	
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
		return value != null ? value : [];
	}
	
	function optionalStr(value) {
		return value != null ? value : "";
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
	
	function toOP(str) {
		return keyMapping[str] || str;
	}
	
	function toId(str) {
		return idenMapping[str] || str;
	}
	
	function filledArray(count, value) {
		var result = new Array(count), i;

		for (i = 0; i < count; i++) {
			result[i] = value;
		}

		return result;
	}
	
	function moduleName(str) {
		var mod = str, m = /^..?\/.*?([\w-]+)(\.\w+)?$/.exec(str);
		if (m) {
			mod = m[1];
		}
		mod = mod.replace(/-/g, '_');
		return mod;
	}
	
	function parseDecLiteral(str) {
		return str.replace(/(very|VERY)/, "e");
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

/** Skipped */
__
	= (WhiteSpace / LineTerminatorSequence / Comment)*

_
	= (WhiteSpace / MultiLineCommentNoLineTerminator)*

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
	/ IfStatement
	/ WhileStatement
	/* ForStatement */

/* Source Element without Wow Statement */
SourceElementNoWow = !WowStatement b:SourceElement {return b;}

/** 2.1 Statements */
/* Statement */
Statement
	= DeclarationStatement
	/ AssignmentStatement
	/ WowStatement
	/ ExpressionStatement
	/ TrainedStatement
	/ ImportStatement
	/ ExportStatement
	/ DeboogerStatement
	/ BarkStatement
	/* JSStatement */

/* Variable declarations */
DeclarationStatement
	= "very" __ iden:Identifier expr:(__ "is" __ Expression)? EOS
	{
		return {
			"type": "VariableDeclaration",
			"declarations": [
				{
					"type": "VariableDeclarator",
					"id": iden,
					"init": extractOptional(expr, 3)
				}
			],
			"kind": "var"
		};
	}
	/ "always" __ iden:Identifier expr:(__ "is" __ Expression)? EOS
	{
		return {
			"type": "VariableDeclaration",
			"declarations": [
				{
					"type": "VariableDeclarator",
					"id": iden,
					"init": extractOptional(expr, 3)
				}
			],
			"kind": "const"
		};
	}

/* AssignmentStatement */
AssignmentStatement
	= iden:MemberExpression __ ("as"/"=") __ expr:Expression EOS
	{
		return {
			"type": "ExpressionStatement",
			"expression": {
				"type": "AssignmentExpression",
				"operator": "=",
				"left": iden,
				"right": expr
			}
		}
	}

/* Wow: ends block */
WowStatement
	= ("wow"/"wow&") _ v:Expression? EOS
	{
		return {
			"type": "ReturnStatement",
			"argument": v
		}
	}

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
	= "trained" EOS
	{
		return {
			"type": "ExpressionStatement",
			"expression": {
				"type": "Literal",
				"value": "use strict",
				"raw": "\"use strict\""
			}
		}
	}

/* ImportStatement */
ImportStatement
	= "so" __ str:(Identifier / StringLiteral) as:(__ "as" __ (Identifier / StringLiteral))? EOS
	{
		var _as = optionalList(extractOptional(as, 3));
		var asName;
		
		if ('name' in _as) asName = _as['name'];
		else if ('value' in _as) asName = _as['value'];
		else if ('name' in str) asName = str['name'];
		else if ('value' in str) asName = str['value'];
		
		return {
			"type": "VariableDeclaration",
			"declarations": [{
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
					"arguments": [{
						"type": "Literal",
						"value": str['name'] || str['value']
					}]
				}
			}],
			"kind": "var"
		}
	}

/* Export Statement */
ExportStatement
	= "out" __ expr:Expression
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
	= "debooger" EOS
	{
		return {
			"type": "DebuggerStatement"
		}
	}

/* Bark Statement */
BarkStatement
	= "bark" EOS
	{
		return {
			"type": "BreakStatement"
		}
	}

/** 2.1.1 Blocks */
BlockNoWow
	= first:SourceElementNoWow rest:(__ SourceElementNoWow)*
	{		
		return {
			"type": "BlockStatement",
			"body": buildList(first, rest, 1)
		}
	}

/** 2.2 Values */
Value
	= thisValue
	/ Identifier
	/ Literal

Literal
	= NullLiteral
	/ BooleanLiteral
	/ DSONLiteral
	/ NumericLiteral
	/ StringLiteral
	/ ArrayLiteral

thisValue
	= "this"
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

/* Reserved Words */
ReservedWord
	= "such" / "wow" / "wow&" / "plz" / "dose" / "very" / "shh" / "quiet" / "loud" / "rly" / "but" / "many" / "much" / "so" / "trained" / "debooger" / "bark" / "always" / "notrly" / "dogeof" / "maybe" / "yes" / $(!"notrly" "no") / "empty"
	/ "typeof" / "true" / "false" / "null" / "void" / "delete"

/** Literals */
/* Null Literals */
NullLiteral
	= ("null" / "empty") { return { type: "Literal", value: null }; }

/* Boolean Literals */
BooleanLiteral
	= ("true" / "yes") { return { type: "Literal", value: true }; }
	/ ("false" / $(!"notrly" "no")) { return { type: "Literal", value: false }; }
	/ "maybe" { return maybeOP; }

/* Numeric Literals */
NumericLiteral
	= literal:DecimalLiteral !(IdentifierStart / DecimalDigit) {return literal;}

/* Decimal Literals */
DecimalLiteral
	= DecimalIntegerLiteral "." DecimalDigit* ExponentPart?
	{
		return {
			"type": "Literal",
			"value": parseFloat(parseDecLiteral(text())),
			"raw": "\"" + parseDecLiteral(text()) + "\""
		};
	}
	/ "." DecimalDigit+ ExponentPart?
	{
		return {
			"type": "Literal",
			"value": parseFloat(parseDecLiteral(text())),
			"raw": "\"" + parseDecLiteral(text()) + "\""
		};
	}
	/ DecimalIntegerLiteral+ ExponentPart?
	{
		return {
			"type": "Literal",
			"value": parseInt(parseDecLiteral(text())),
			"raw": "\"" + parseDecLiteral(text()) + "\""
		};
	}

DecimalIntegerLiteral
	= "0"
	/ NonZeroDigit DecimalDigit*

DecimalDigit
	= [0-9]

NonZeroDigit
	= [1-9]

/** ExponentPart */
ExponentPart
	= ExponentIndicator SignedInteger

ExponentIndicator
	= "e"i / "very"i

SignedInteger
	= [+-]? DecimalDigit+

/* String Literals */
StringLiteral
	= "'" literal:SourceCharacterNoQuote1* "'"
	{
		return {
			"type": "Literal",
			"value": literal.join(""),
			"raw": text()
		};
	}
	/ '"' literal:SourceCharacterNoQuote2* '"'
	{
		return {
			"type": "Literal",
			"value": literal.join(""),
			"raw": text()
		};
	}

/** DSON Literals */
DSONLiteral
	= "{{" __ obj:DSONObject __ "}}" {return obj}

DSONObject
	= "such" __ member:DSONMembers? __ "wow"
	{
		return {
			"type": "ObjectExpression",
			"properties": optionalList(member)
		}
	}

DSONMembers
	= first:DSONPair rest:(__ DSONMemberSeparator __ DSONPair)*
	{
		return buildList(first, rest, 3);
	}

DSONMemberSeparator
	= "," / "." / "!" / "?"

DSONPair
	= key:StringLiteral __ "is" __ value:DSONValue
	{
		return {
			"key": key,
			"value": value,
			"kind": "init"
		}
	}

DSONArray
	= "so" __ elements:DSONArrayElements? __ "many"
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
	= "and" / "also"

DSONValue
	= Identifier
	/ StringLiteral
	/ NumericLiteral
	/ DSONObject
	/ DSONArray
	/ "yes" {return {"type": "Identifier", "name": true}}
	/ "no" {return {"type": "Identifier", "name": false}}
	/ "empty" {return {"type": "Identifier", "name": null}}

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
	= FunctionCallExpression
	/ NewExpression
	/ AssignmentExpression
	/ LogicalExpression
	/ ComparisonExpression
	/ AdditiveExpression
	/ UnaryExpression
	/ Value

/* "Algebra" expressions */
MultiplicativeExpression
	= left:Primary __ op:MultiplicativeOperator __ right:MultiplicativeExpression
	{
		return {
			"type": "BinaryExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		}
	}
	/ Primary

MultiplicativeOperator
	= "*" / "/" / "%"

AdditiveExpression
	= left:MultiplicativeExpression __ op:AdditiveOperator __ right:AdditiveExpression
	{
		return {
			"type": "BinaryExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		}
	}
	/ MultiplicativeExpression

AdditiveOperator
	= "+" / "-"

Primary
	= Value
	/ "(" __ left:Expression __ ")" {return left;}

/* Logical expressions */
LogicalExpression
	= left:AdditiveExpression __ op:LogicalOperator __ right:AdditiveExpression
	{
		return {
			"type": "LogicalExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		}
	}

LogicalOperator
	= ("and" / "or" / "&&" / "||")

LeftHandSideExpression
	= FunctionCallExpression / NewExpression / Value

/* Unary expressions */
PostfixExpression
	= argument:LeftHandSideExpression _ operator:PostfixOperator
	{
		return {
			"type": "UpdateExpression",
			"operator": operator,
			"argument": argument,
			"prefix": false
		}
	}
	/ LeftHandSideExpression

PostfixOperator
	= "++" / "--"

UnaryExpression
	= PostfixExpression
	/ op:UnaryOperator __ argument:UnaryExpression
	{
		return {
			"type": "UnaryExpression",
			"operator": toOP(op),
			"argument": argument,
			"prefix": true
		}
	}

UnaryOperator
	= "dogeof" / "notrly"
	/ "delete" / "void" / "typeof" / "!" / "~"

/* Comparison */
ComparisonExpression
	= left:LeftHandSideExpression __ op:ComparisonOperator __ right:AdditiveExpression
	{
		return {
			"type": "BinaryExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		}
	}

ComparisonOperator
	= "not" / "smallerish" / "smaller" / "biggerish" / "bigger" / "is" / "shibeof"
	/ "!==" / ">=" / ">" / "<=" / "<" / "===" / "instanceof"

/* Function Call Expressions */
FunctionCallExpression
	= "plz" __ iden:MemberExpression args:(__ "with" __ FunctionArguments)?
	{
		return {
			"type": "CallExpression",
			"callee": iden,
			"arguments": extractOptional(args, 3) || []
		}
	}
	
/* New Expressions */
NewExpression
	= "new" __ iden:MemberExpression args:(__ "with" __ FunctionArguments)?
	{
		return {
			"type": "NewExpression",
			"callee": iden,
			"arguments": extractOptional(args, 3) || []
		}
	}

/* AssignmentExpression */
AssignmentExpression
	= left:LeftHandSideExpression _ op:AssignmentOperator __ right:Expression
	{
		return {
			"type": "AssignmentExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		};
	}

AssignmentOperator
	= "as" / "more" / "less" / "lots" / "few"
	/ "=" / "+=" / "-=" / "*=" / "/="

MemberExpression
	= first:(
		Primary
		/ FunctionCallExpression
		/ "new" __ callee:MemberExpression (__ "with" __ FunctionArguments)?
		{
			return {
				"type": "NewExpression",
				"callee": iden,
				"arguments": extractOptional(args, 3) || []
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
		var result = first, i;
		for (i = 0; i < rest.length; i++){
			result = {
				"type": "MemberExpression",
				"object": result,
				"property": rest[i].property,
				"computed": rest[i].computed,
			};
		}
		return result;
	}

/** 2.4 Function declarations */
FunctionDeclaration
	= "such" __ iden:Identifier EOS __ block:BlockNoWow? __ wow:WowStatement
	{
		fnBlock = block || {
			"type": "BlockStatement",
			"body": []
		};
		fnBlock.body.push(wow);
		
		return {
			"type": "FunctionDeclaration",
			"id": iden,
			"params": [],
			"default": [],
			"body": fnBlock,
			
			"rest": null,
			"generator": false,
			"expression": false
		}
	}
	/ "such" __ iden:Identifier __ "much" __ args:FunctionArguments EOS __ block:BlockNoWow? __ wow:WowStatement
	{
		fnBlock = block || {
			"type": "BlockStatement",
			"body": []
		};
		fnBlock.body.push(wow);
		
		return {
			"type": "FunctionDeclaration",
			"id": iden,
			"params": args,
			"default": [],
			"body": fnBlock,
			
			"rest": null,
			"generator": false,
			"expression": false
		}
	}

FunctionArguments "arguments"
	= first:Expression rest:(__ "," __ Expression)*
	{
		return buildList(first, rest, 3);
	}

/** 2.5 If Statements */
IfStatement
	= "rly" __ test:Expression EOS __ block:BlockNoWow? __ IfWowStatement
	{
		return {
			"type": "IfStatement",
			"test": test,
			"consequent": block,
			"alternate": null
		}
	}
	/ "rly" __ test:Expression EOS __ block:BlockNoWow? __ alt:ElseStatement
	{
		return {
			"type": "IfStatement",
			"test": test,
			"consequent": block,
			"alternate": alt
		}
	}

IfWowStatement = "wow" EOS

/** 2.5.1 Else Statements */
ElseStatement
	= "but" __ block:IfStatement {return block;}
	/ "but" __ block:BlockNoWow? __ IfWowStatement {return block;}

/** 2.6 While Statements */
WhileStatement
	= "many" __ test:Expression EOS block:BlockNoWow? __ WowStatement
	{
		return {
			"type": "WhileStatement",
			"test": test,
			"body": block
		}
	}

/** 2.7 For Statements (BETA) (DO NOT USE) */
ForStatement
	= "much" __
	init:(Expression __)? ForNext __
	test:(Expression __)? ForNext __
	update:(Expression __)? EOS
	body:(BlockNoWow EOS)?
	WowStatement
	{
		return {
			"type": "ForStatement",
			"init": extractOptional(init, 0),
			"test": extractOptional(test, 0),
			"update": extractOptional(update, 0),
			"body": extractOptional(body, 0)
		}
	}

ForNext = "next" / ';'