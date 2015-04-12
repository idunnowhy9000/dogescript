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
				operator: toOP(element[1]),
				left: result,
				right: element[3]
			};
		});
	}
	
	function buildLogicalExpression(first, rest) {
		return buildTree(first, rest, function(result, element) {
			return {
				type: "LogicalExpression",
				operator: toOP(element[1]),
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

NEWLINE = [\n\r]

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
	/ ForStatement
	/ TryStatement

/** 2.1 Statements */
/* Statement */
Statement
	= ExpressionStatement
	/ DeclarationStatement
	/ AssignmentStatement
	/ WowStatement
	/ TrainedStatement
	/ ImportStatement
	/ ExportStatement
	/ DeboogerStatement
	/ BarkStatement
	/ ThrowStatement

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
	/* Constant declarations require rhs expression */
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
	= ass:AssignmentExpression EOS
	{
		return ass;
	}

/* Wow: ends block */
WowStatement
	= "wow" _ v:Expression EOS
	{
		return {
			"type": "ReturnStatement",
			"argument": v
		}
	}

EmptyWowStatement = "wow" EOS

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
				"value": "use strict"
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
	= "such" / "wow" / "plz" / "dose" / "very" / "shh" / "quiet" / "loud" / "rly" / "but" / "many" / "much" / "so" / "trained" / "debooger" / "bark" / "always" / "notrly" / "dogeof" / "maybe" / "yes" / $(!"notrly" "no") / "empty" / "retrieve"
	/ "typeof" / "true" / "false" / "null" / "void" / "delete" / "try" / "catch" / "new"

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
			"value": parseFloat(parseDecLiteral(text()))
		};
	}
	/ "." DecimalDigit+ ExponentPart?
	{
		return {
			"type": "Literal",
			"value": parseFloat(parseDecLiteral(text()))
		};
	}
	/ DecimalIntegerLiteral+ ExponentPart?
	{
		return {
			"type": "Literal",
			"value": parseInt(parseDecLiteral(text()))
		};
	}

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
StringLiteral
	= "'" literal:SourceCharacterNoQuote1* "'"
	{
		return {
			"type": "Literal",
			"value": literal.join("")
		};
	}
	/ '"' literal:SourceCharacterNoQuote2* '"'
	{
		return {
			"type": "Literal",
			"value": literal.join("")
		};
	}

/* Object Literals */
ObjectLiteral
	= "{" __ "}" {return { "type": "ObjectExpression", "properties": [] };}
	/ "{" __ obj:JSONMembers __ "}" {return { "type": "ObjectExpression", "properties": obj };}

JSONMembers
	= first:JSONPair rest:(__ "," __ JSONPair)*
	{
		return buildList(first, rest, 3);
	}

JSONPair
	= key:JSONPropertyName __ ":" __ value:Expression
	{
		return {
			"key": key,
			"value": value,
			"kind": "init"
		}
	}

JSONPropertyName
	= IdentifierName
	/ StringLiteral
	/ NumericLiteral

/** DSON Literals */
DSONLiteral
	= "{{" __ "}}" { return { "type": "ObjectExpression", "properties": [] }; }
	/ "{{" __ obj:DSONObject __ "}}" { return { "type": "ObjectExpression", "properties": obj }; }

DSONObject
	= "such" __ member:DSONMembers? __ "wow" { return optionalList(member); }

DSONMembers
	= first:DSONPair rest:(__ DSONMemberSeparator __ DSONPair)* { return buildList(first, rest, 3); }

DSONMemberSeparator
	= "," / "." / "!" / "?"

DSONPair
	= key:JSONPropertyName __ "is" __ value:DSONValue
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
	= "or" / "||"

LogicalANDExpression
	= first:ComparisonExpression rest:(__ LogicalANDOperator __ ComparisonExpression)*
	{ return buildLogicalExpression(first, rest); }

LogicalANDOperator
	= "and" / "&&"

LeftHandSideExpression
	= FunctionCallExpression / NewExpression

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
	/ op:UnaryOperator __ argument:UnaryExpression
	{
		return {
			"type": "UnaryExpression",
			"operator": toOP(op),
			"argument": argument,
			"prefix": true
		};
	}

UnaryOperator
	= "dogeof" / "notrly"
	/ "delete" / "void" / "typeof" / "!" / "~" / "++" / "--" / "+" / "-"

/* Comparison */
ComparisonExpression
	= first:RelationalExpression rest:(__ ComparisonOperator __ RelationalExpression)*
	{ return buildBinaryExpression(first, rest); }

ComparisonOperator
	= "not" / "is"
	/ "!==" / "===" / "==" / "!="

/* Relationals */
RelationalExpression
	= first:AdditiveExpression rest:(__ RelationalOperator __ AdditiveExpression)*
	{ return buildBinaryExpression(first, rest); }
	
RelationalOperator
	= "smallerish" / "smaller" / "biggerish" / "bigger" / "shibeof"
	/ "<=" / "<" / ">=" / ">" / "instanceof"

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
	= MemberExpression
	/ "new" __ iden:MemberExpression args:(__ "with" __ FunctionArguments)?
	{
		return {
			"type": "NewExpression",
			"callee": iden,
			"arguments": extractOptional(args, 3) || []
		}
	}

/* AssignmentExpression */
AssignmentExpression
	= left:LeftHandSideExpression __ (("=" !"=") / "as") __ right:Expression
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
			"operator": toOP(op),
			"left": left,
			"right": right
		};
	}
	/ LogicalORExpression

AssignmentOperator
	= "as" / "more" / "less" / "lots" / "few"
	/ "=" / "+=" / "-=" / "*=" / "/="

MemberExpression
	= first:(
		Primary
		/ FunctionExpression
		/ "new" __ iden:MemberExpression args:(__ "with" __ FunctionArguments)?
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
	= "such" __ iden:Identifier args:(__ "much" __ FormalParameterList)? NEWLINE block:Block EmptyWowStatement
	{
		return {
			"type": "FunctionDeclaration",
			"id": iden,
			"params": args ? args[3] : [],
			"body": block,
			
			"rest": null,
			"generator": false,
			"expression": false
		}
	}

FunctionExpression	
	= "much" __ args:(FormalParameterList)? NEWLINE body:Block EmptyWowStatement
	{
		return {
			"type": "FunctionExpression",
			"id": null,
			"params": optionalList(args),
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
	= "rly" __ test:Expression NEWLINE block:Block _else:(EmptyWowStatement {return null;} / ElseStatement)
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
	= "but" __ block:IfStatement {return block;}
	/ "but" NEWLINE block:Block EmptyWowStatement {return block;}

/** 2.6 While Statements */
WhileStatement
	= "many" __ test:Expression NEWLINE block:Block EmptyWowStatement
	{
		return {
			"type": "WhileStatement",
			"test": test,
			"body": block
		};
	}

/** 2.7 For Statements */
ForStatement
	= "much" __
	init:("very" __ AssignmentExpression __)? ForNext __
	test:(Expression __)? ForNext __
	update:Expression? NEWLINE
	body:Block
	EmptyWowStatement
	{
		return {
			"type": "ForStatement",
			"init": extractOptional(init, 0),
			"test": extractOptional(test, 0),
			"update": update,
			"body": body
		};
	}

ForNext = "next" / ';'

/** 2.8 Try-Catch-Finally Statements */
TryStatement
	= "try" NEWLINE block:Block handler:Catch finalizer:Finally
	{
		return {
			"type": "TryStatement",
			"block": block,
			"handler": handler,
			"finalizer": finalizer
		};
	}
	/ "try" NEWLINE block:Block handler:Catch
	{
		return {
			"type": "TryStatement",
			"block": block,
			"handler": handler,
			"finalizer": null
		};
	}
	/ "try" NEWLINE block:Block finalizer:Finally
	{
		return {
			"type": "TryStatement",
			"block": block,
			"handler": null,
			"finalizer": finalizer
		};
	}

Catch
	= "catch" __ param:Identifier NEWLINE body:Block
	{
		return {
			"type": "CatchClause",
			"param": param,
			"body": body
		};
	}

Finally
	= "retrieve" NEWLINE body:Block
	{
		return body;
	}

/** 2.9 Throw Statement */
ThrowStatement
	= "throw" __ left:Expression EOS
	{
		return {
			"type": "ThrowStatement",
			"argument": left
		};
	}