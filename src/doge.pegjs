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
	
	function makeVarDeclare(iden, expr) {
		return [{
			"type": "VariableDeclarator",
			"id": iden,
			"init": expr == null ? null : expr
		}];
	}
	
	function toOP(str) {
		return keyMapping[str] || str;
	}
	
	function maybeOP () {
		return {
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
							"name": "round"
						}
					},
					"arguments": [{
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
					}]
				},
				"prefix": true
			},
		}
	}
}

start = __ program:Program __ {return program;}

/** 1. Lexical Grammar */

/* End of statement */
EOS = ";" / LineTerminator

/* Source Character */
SourceCharacter = .

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
LineTerminator = ("\n"/"\r"/"\u2028"/"\u2029")

/* Line Terminator Sequence */
LineTerminatorSequence "end of line"
	= "\n"
	/ "\r\n"
	/ "\r"
	/ "\u2028"
	/ "\u2029"

/* Comment */
Comment "comment"
	= SingleLineComment / MultiLineComment

/* Multi-line Comment */
MultiLineComment
	= "quiet" _u (!(_u "loud") SourceCharacter)* _u "loud"

MultiLineCommentNoLineTerminator
	= "quiet" _u (!((_u "loud") / LineTerminator) SourceCharacter)* _u "loud"

/* Single-line Comment */
SingleLineComment
	= "shh" WhiteSpace (!LineTerminator SourceCharacter)*

/** Skipped */

_u
	= (WhiteSpace / LineTerminatorSequence)*

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
	
/* Identifiers */
Identifier
	= !ReservedWord name:IdentifierName {return name;}

IdentifierName "identifier"
	= first:("$"/"_")? rest:([a-zA-Z0-9])+
	{
		return {
			"type": "Identifier",
			"name": optionalStr(first) + rest.join("")
		};
	}

/* Reserved Words */
ReservedWord
	= "such" / "wow" / "wow&" / "plz" / "dose" / "very" / "shh" / "quiet" / "loud" / "rly" / "but" / "many" / "much" / "so" / "trained" / "debooger" / "maybe"

/** 2.1 Statements */
/* Statement */
Statement
	= DeclarationStatement
	/ WowStatement
	/ ExpressionStatement
	/ TrainedStatement
	/ ImportStatement
	/ DeboogerStatement

/* Variable declarations */
DeclarationStatement
	= "very" __ iden:Identifier expr:(__ "is" __ Expression)? (__ EOS)?
	{
		return {
			"type": "VariableDeclaration",
			"declarations": makeVarDeclare(iden, extractOptional(expr, 3)),
			"kind": "var"
		};
	}
	/ "always" __ iden:Identifier expr:(__ "is" __ Expression)? (__ EOS)?
	{
		return {
			"type": "VariableDeclaration",
			"declarations": makeVarDeclare(iden, extractOptional(expr, 3)),
			"kind": "const"
		};
	}

/* Wow: ends block */
WowStatement
	= "wow" _ v:Value (__ EOS)?
	{
		return {
			"type": "ReturnStatement",
			"argument": v
		}
	}
	/ "wow" (__ EOS)?
	{
		return {
			"type": "ReturnStatement",
			"argument": null
		}
	}

/* ExpressionStatement */
ExpressionStatement
	= expr:Expression (__ EOS)?
	{
		return {
			"type": "ExpressionStatement",
			"expression": expr
		}
	}

/* Trained Statement */
TrainedStatement
	= "trained" (__ EOS)?
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
	= "so" __ str:Identifier as:(__ "as" __ Identifier)? (__ EOS)?
	{
		return {
			"type": "VariableDeclaration",
			"declarations": makeVarDeclare({
				"type": "Identifier",
				"name": extractOptional(as, 3) || str.name
			}, {
				"type": "CallExpression",
				"callee": {
					"type": "Identifier",
					"name": "require"
				},
				"arguments": {
					"type": "Literal",
					"value": str.name,
					"raw": str.name
				}
			})
		}
	}

/* DeboogerStatement */
DeboogerStatement
	= "debooger" (__ EOS)?
	{
		return {
			"type": "DebuggerStatement"
		}
	}

/** 2.1.1 Blocks */
BlockNoWow
	= src:(SourceElementNoWow (__ SourceElementNoWow)*)?
	{
		if (src == null) {
			return {
				"type": "BlockStatement",
				"body": []
			}
		}
		
		return {
			"type": "BlockStatement",
			"body": buildList(src[0], src[1], 1)
		}
	}

/** 2.2 Values */
Value
	= thisValue
	/ Literal
	/ Identifier
	/ MemberExpression

thisValue
	= "this"
	{
		return {
			"type": "ThisExpression"
		};
	}

Literal
	= NumLiteral / StringLiteral / BooleanLiteral

NumLiteral
	= literal:([0-9]+ / [0-9]* "." [0-9]+) ("e" [+-]? [0-9]+)?
	{
		return {
			"type": "Literal",
			"value": parseFloat(literal.join("")),
			"raw": literal.join("")
		};
	}

StringLiteral
	= "'" literal:SourceCharacterNoQuote1* "'"
	{
		return {
			"type": "Literal",
			"value": literal.join(""),
			"raw": literal.join("")
		};
	}
	/ '"' literal:SourceCharacterNoQuote2* '"'
	{
		return {
			"type": "Literal",
			"value": literal.join(""),
			"raw": literal.join("")
		};
	}

BooleanLiteral
	= bool:("true"/"false"/"maybe")
	{
		if (bool === "maybe") return maybeOP();
		
		return {
			"type": "Identifier",
			"name": bool
		}
	}

/** 2.3 Expression */
/* Expressions */
Expression
	= MemberExpression
	/ FunctionCallExpression
	/ AssignmentExpression
	/ UnaryExpression
	/ LogicalExpression
	/ Additive
	/ Value

/* "Algebra" expressions */
Additive
	= left:Multiplicative _ op:("not"/"smallerish"/"biggerish"/"smaller"/"bigger"/"+"/"-"/"instanceof"/"is"/"==="/"!=="/"<="/">="/"<"/">") _ right:Additive
	{
		return {
			"type": "BinaryExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		};
	}
	/ Multiplicative

Multiplicative
	= left:Primary _ op:("*"/"/") _ right:Multiplicative
	{
		return {
			"type": "BinaryExpression",
			"operator": op,
			"left": left,
			"right": right
		};
	}
	/ Primary

Primary
	= Value
	/ "(" _ additive:Additive _ ")" {return additive;}

/* Logical expressions */
LogicalExpression
	= left:Primary _ op:("and" / "or" / "&&" / "||") _ right:Primary
	{
		return {
			"type": "LogicalExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		}
	}
	
/* Unary expressions */
UnaryExpression
	= op:("dogeof" / "shibeof" /"notrly" / "typeof" / "!") _ argument:Expression
	{
		return {
			"type": "UnaryExpression",
			"operator": toOP(op),
			"argument": argument,
			"prefix": true
		}
	}

/* Function Call Expressions */
FunctionCallExpression
	= "plz" _ iden:Identifier args:(_ "with" _ FunctionArguments)?
	{
		return {
			"type": "CallExpression",
			"callee": iden,
			"arguments": extractOptional(args, 3) || []
		}
	}

/* AssignmentExpression */
AssignmentExpression
	= left:Identifier _ op:("="/"+="/"-="/"*="/"/="/"as"/"more"/"less"/"lots"/"few") _ right:Expression
	{
		return {
			"type": "AssignmentExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		};
	}

MemberExpression
	= object:Identifier "." property:Identifier
	{
		return {
			"type": "MemberExpression",
			"computed": false,
			"object": object,
			"property": property
		}
	}
	/ object:Identifier "[" property:Expression "]"
	{
		return {
			"type": "MemberExpression",
			"computed": true,
			"object": object,
			"property": property
		}
	}

/** 2.4 Function declarations */
FunctionDeclaration
	= "such" _ iden:Identifier EOS block:(BlockNoWow EOS)? wow:WowStatement
	{
		fnBlock = extractOptional(block, 0) || [];
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
	/ "such" _ iden:Identifier _ "much" _ args:FunctionArguments EOS block:(BlockNoWow EOS)? WowStatement
	{
		fnBlock = extractOptional(block, 0) || [];
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

FunctionArguments
	= first:Expression rest:(_ Expression)*
	{
		return buildList(first, rest, 1);
	}

/** 2.5 If Statements */
IfStatement
	= "rly" __ test:Expression EOS block:(BlockNoWow EOS)? WowStatement
	{
		return {
			"type": "IfStatement",
			"test": test,
			"consequent": extractOptional(block, 0),
			"alternate": null
		}
	}
	/ "rly" __ test:Expression EOS block:(BlockNoWow EOS)? __ alt:ElseStatement
	{
		return {
			"type": "IfStatement",
			"test": test,
			"consequent": extractOptional(block, 0),
			"alternate": alt
		}
	}

/** 2.5.1 Else Statements */
ElseStatement
	= "but" __ block:IfStatement
	{
		return block;
	}
	/ "but" __ block:BlockNoWow
	{
		return {
			"type": "BlockStatement",
			"body": block
		}
	}

/** 2.6 While Statements */
WhileStatement
	= "many" __ test:Expression EOS block:(BlockNoWow EOS)? __ WowStatement
	{
		return {
			"type": "WhileStatement",
			"test": test,
			"body": extractOptional(block, 0)
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