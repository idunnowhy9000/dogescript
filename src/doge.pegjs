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
	
	var idenMapping = {
		"yes": "true",
		"no": "false",
		"empty": "null"
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
	
	function toId(str) {
		return idenMapping[str] || str;
	}
	
	function moduleName(str) {
		var mod = str, m = /^..?\/.*?([\w-]+)(\.\w+)?$/.exec(str);
		if (m) {
			mod = m[1];
		}
		mod = mod.replace(/-/g, '_');
		return mod;
	}
}

start = __ program:Program __ {return program;}

/** 1. Lexical Grammar */

/* End of statement */
EOS
	= EOF
	/ ";"
	/ LineTerminator

/* EOF */
EOF "end of file"
	= !.

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
Comment
	= SingleLineComment
	/ MultiLineComment

/* Multi-line Comment */
MultiLineComment
	= "quiet" _u (!(_u "loud") SourceCharacter)* _u "loud"

MultiLineCommentNoLineTerminator
	= "quiet" _u (!((_u "loud") / LineTerminator) SourceCharacter)* _u "loud"

/* Single-line Comment */
SingleLineComment
	= "shh" (!LineTerminator SourceCharacter)*

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
		var _t = optionalStr(first) + rest.join("");
		if (_t === "maybe") return maybeOP;
		
		return {
			"type": "Identifier",
			"name": toId(_t)
		};
	}

/* Reserved Words */
ReservedWord
	= "such" / "wow" / "wow&" / "plz" / "dose" / "very" / "shh" / "quiet" / "loud" / "rly" / "but" / "many" / "much" / "so" / "trained" / "debooger" / "maybe" / "bark" / "always"

/** 2.1 Statements */
/* Statement */
Statement
	= DeclarationStatement
	/ AssignmentStatement
	/ WowStatement
	/ ExpressionStatement
	/ TrainedStatement
	/ ImportStatement
	/ DeboogerStatement
	/ BarkStatement
	/* JSStatement */

/* Variable declarations */
DeclarationStatement
	= "very" __ iden:Identifier expr:(__ "is" __ Expression)? EOS
	{
		return {
			"type": "VariableDeclaration",
			"declarations": makeVarDeclare(iden, extractOptional(expr, 3)),
			"kind": "var"
		};
	}
	/ "always" __ iden:Identifier expr:(__ "is" __ Expression)? EOS
	{
		return {
			"type": "VariableDeclaration",
			"declarations": makeVarDeclare(iden, extractOptional(expr, 3)),
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
	= "so" __ str:StringLiteral as:(__ "as" __ Identifier)? EOS
	{
		return {
			"type": "X-Require-Statement",
			"name": moduleName(as != null ? as[3].name : str.value),
			"argument": str.value
		}
	}
	/ "so" __ str:Identifier as:(__ "as" __ Identifier)? EOS
	{
		return {
			"type": "X-Require-Statement",
			"name": moduleName(as != null ? as[3].name : str.name),
			"argument": str.name
		}
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
	/ DSONLiteral
	/ NumLiteral
	/ StringLiteral
	/ ArrayLiteral

thisValue
	= "this"
	{
		return {
			"type": "ThisExpression"
		};
	}

NumLiteral
	= DecimalIntegerLiteral ("." DecimalDigit*)?
	{
		return {
			"type": "Literal",
			"value": parseFloat(text()),
			"raw": JSON.stringify(text())
		};
	}
	/ "." DecimalDigit+
	{
		return {
			"type": "Literal",
			"value": parseFloat(text()),
			"raw": JSON.stringify(text())
		};
	}

DecimalIntegerLiteral
	= "0"
	/ NonZeroDigit DecimalDigit*

DecimalDigit
	= [0-9]

NonZeroDigit
	= [1-9]

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

DSONSourceCharacter
	= !"}" char:SourceCharacter {return char;}

DSONLiteral
	= "{{" literal:DSONSourceCharacter* "}}"
	{
		return {
			"type": "X-DSON-Literal",
			"source": literal.join("")
		};
	}

ArrayLiteral
	= "[" e:ArrayElements "]"
	{
		return {
			"type": "ArrayExpression",
			"elements": e
		}
	}

ArrayElements
	= first:ArrayElement rest:("," __ ArrayElement)* { return buildList(first, rest, 2); }

ArrayElement
	= Expression
	/ {return null;}

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
	/ UnaryExpression
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
	
/* Unary expressions */
UnaryExpression
	= op:UnaryOperator __ argument:MemberExpression
	{
		return {
			"type": "UnaryExpression",
			"operator": toOP(op),
			"argument": argument,
			"prefix": true
		}
	}

UnaryOperator
	= "dogeof" /"notrly" / "typeof" / "!"

/* Comparison */
ComparisonExpression
	= left:AdditiveExpression __ op:ComparisonOperator __ right:AdditiveExpression
	{
		return {
			"type": "BinaryExpression",
			"operator": toOP(op),
			"left": left,
			"right": right
		}
	}

ComparisonOperator
	= "not" / "smallerish" / "smaller" / "biggerish" / "bigger" / "is"
	/ "!==" / ">=" / ">" / "<=" / "<" / "==="

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
	= left:Identifier _ op:AssignmentOperator __ right:Expression
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
		/ __ "." __ property:IdentifierName {
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

FunctionArguments
	= first:Expression rest:("," __ Expression)*
	{
		return buildList(first, rest, 2);
	}

/** 2.5 If Statements */
IfStatement
	= "rly" __ test:Expression EOS __ block:BlockNoWow? __ IfWowStatement EOS
	{
		return {
			"type": "IfStatement",
			"test": test,
			"consequent": block,
			"alternate": null
		}
	}
	/ "rly" __ test:Expression EOS __ block:BlockNoWow? __ alt:ElseStatement EOS
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
	= "many" __ test:Expression EOS block:(BlockNoWow? EOS)? __ WowStatement
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

/** 2.8 JS Statements, */
JSStatement
	= "@'" source:SourceCharacterNoQuote1* "'" EOS
	{
		return {
			"type": "X-JS-Statement",
			"source": source.join("")
		}
	}
	/ '@"' source:SourceCharacterNoQuote2* '"' EOS
	{
		return {
			"type": "X-JS-Statement",
			"source": source.join("")
		}
	}