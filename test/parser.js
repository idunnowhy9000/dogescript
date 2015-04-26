var assert = require("assert"),
	parser = require('../lib/parser.js');

describe("Parser", function () {
	describe("parse expressions", function () {
		describe("parse values", function () {
			it("should parse literals", function () {
				// number 
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":1}}]}, parser.parse("1"), "Expected number '1'.");
				
				// string
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":"hello world!"}}]}, parser.parse("'hello world!'"), "Expected string 'hello world!'");
				
				// identifier
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Identifier","name":"apple"}}]}, parser.parse('apple'), "Expected identifier 'apple'");
				
				// booleans
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":true}}]}, parser.parse('yes'), "Expected identifier 'true'");
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":false}}]}, parser.parse('no'), "Expected identifier 'false'");
				
				// null
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":null}}]}, parser.parse('null'), "Expected identifier 'null'");
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":null}}]}, parser.parse('empty'), "Expected identifier 'null'");
			});
			
			it("should parse member expressions", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"MemberExpression","computed":true,"object":{"type":"MemberExpression","computed":false,"object":{"type":"Identifier","name":"a"},"property":{"type":"Identifier","name":"b"}},"property":{"type":"Literal","value":"c"}}}]}, parser.parse('a.b["c"]'), 'Expected a.b["c"]');
			});
		});
		
		describe("parse algebraic expressions", function () {
			it("should parse binary and logical expressions in the correct order", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"BinaryExpression","operator":"/","left":{"type":"LogicalExpression","operator":"||","left":{"type":"LogicalExpression","operator":"&&","left":{"type":"Literal","value":1,},"right":{"type":"Literal","value":2,}},"right":{"type":"BinaryExpression","operator":"+","left":{"type":"Literal","value":3,},"right":{"type":"BinaryExpression","operator":"*","left":{"type":"Literal","value":4,},"right":{"type":"Literal","value":5,}}}},"right":{"type":"Literal","value":6,}}}]}, parser.parse("(1 && 2 || 3 + 4 * 5) / 6"), "Expected binary expression (1 && 2 || 3 + 4 * 5) / 6.");
			});
			
			it("should do comparisons", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"BinaryExpression","operator":"===","left":{"type":"Literal","value":1},"right":{"type":"Literal","value":1}}}]}, parser.parse("1 === 1"), "Expected 1 === 1");
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"BinaryExpression","operator":"!==","left":{"type":"Literal","value":1},"right":{"type":"Literal","value":1}}}]}, parser.parse("1 not 1"), "Expected 1 !== 1");
			});
			
			it("should do unary operators", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"UnaryExpression","operator":"-","argument":{"type":"Literal","value":5},"prefix":true}}]}, parser.parse("-5"), "Expected -5");
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"UpdateExpression","operator":"++","argument":{"type":"Identifier","name":"a"},"prefix":false}}]}, parser.parse("a++"), "Expected a++");
			});
		});
		
		describe("parses function calls", function () {
			it("should parse functions calls", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"CallExpression","callee":{"type":"Identifier","name":"print"},"arguments":[]}}]}, parser.parse("plz print"), "Expected print()");
			});
			
			it("should parse old function calls", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"CallExpression","callee":{"type":"MemberExpression","computed":false,"object":{"type":"Identifier","name":"console"},"property":{"type":"Identifier","name":"log"}},"arguments":[{"type":"Literal","value":"abc"}]}}]}, parser.parse("console dose log with 'abc'"), "Expected 'console.log(\"abc\")'");
			});
			
			it("should parse functions calls with arguments", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"CallExpression","callee":{"type":"Identifier","name":"print"},"arguments":[{"type":"Literal","value":1},{"type":"Literal","value":2}]}}]}, parser.parse("plz print with 1, 2"), "Expected print(1, 2)");
			});
		});
		
		describe("parses assignment expression", function () {
			it("should parse assignment expression", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"AssignmentExpression","operator":"=","left":{"type":"Identifier","name":"a"},"right":{"type":"Identifier","name":"b"}}}]}, parser.parse("a as b"), "Expected 'a = b'");
			});
		});
		
		describe("parses 'new' function call", function () {
			it("should parse 'new' function call", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"NewExpression","callee":{"type":"Identifier","name":"a"},"arguments":[]}}]}, parser.parse("new a"), "Expected 'new a'");
			});
			
			it("should parse 'new' function call with arguments", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"NewExpression","callee":{"type":"Identifier","name":"a"},"arguments":[{"type":"Literal","value":1}]}}]}, parser.parse("new a with 1"), "Expected 'new a(1)'");
			});
		});
	});
	
	describe("parses statements", function () {
		it("should parse variable declarations", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"a"},"init":null}],"kind":"var"}]}, parser.parse("very a"), "Expected 'var a'");
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"a"},"init":{"type":"Literal","value":5}}],"kind":"var"}]}, parser.parse("very a is 5"), "Expected 'var a = 5'");
			
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"a"},"init":null}],"kind":"const"}]}, parser.parse("always a"), "Expected 'const a'");
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"a"},"init":{"type":"Literal","value":5}}],"kind":"const"}]}, parser.parse("always a is 5"), "Expected 'const a = 5'");
		});
		
		it("should parse assignment statements", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"AssignmentExpression","operator":"=","left":{"type":"Identifier","name":"a"},"right":{"type":"Literal","value":1}}}]}, parser.parse("a is 1"), "Expected 'a = 1'");
		});
		
		it("should parse wow statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"ReturnStatement","argument":{"type":"Literal","value":1}}]}, parser.parse("wow 1"), "Expected 'return 1;'");
		});
		
		it("should parse trained statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":"use strict"}}]}, parser.parse("trained"), "Expected 'use strict'");
		});
		
		it("should parse import statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"abc"},"init":{"type":"CallExpression","callee":{"type":"Identifier","name":"require"},"arguments":[{"type":"Literal","value":"abc"}]}}],"kind":"var"}]}, parser.parse("so abc"), "Expected 'var abc = require(\"abc\")'");
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"test"},"init":{"type":"CallExpression","callee":{"type":"Identifier","name":"require"},"arguments":[{"type":"Literal","value":"test.js"}]}}],"kind":"var"}]}, parser.parse('so "test.js"'), "Expected 'var test = require(\"test.js\")'");
		});
		
		it("should parse export statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"AssignmentExpression","operator":"=","left":{"type":"MemberExpression","computed":false,"object":{"type":"Identifier","name":"module"},"property":{"type":"Identifier","name":"exports"}},"right":{"type":"Literal","value":1}}}]}, parser.parse('out 1'), "Expected 'module.exports = 1'");
		});
		
		it("should parse debooger statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"DebuggerStatement"}]}, parser.parse("debooger"), "Expected 'debugger'");
		});
		
		it("should parse bark statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"BreakStatement"}]}, parser.parse("bark"), "Expected 'break'");
		});
		
		it("should parse throw statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"ThrowStatement","argument":{"type":"Literal","value":"Error"}}]}, parser.parse("throw 'Error'"), "Expected 'throw \"Error\"'");
		});
	
		describe("parses if statements", function () {
			it("should parse if statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"IfStatement","test":{"type":"Literal","value":1},"consequent":{"type":"BlockStatement","body":[]},"alternate":null}]}, parser.parse("rly 1\nwow"), "Expected 'if(1) {}'");
			});
			
			it("should parse if-else statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"IfStatement","test":{"type":"Literal","value":1},"consequent":{"type":"BlockStatement","body":[]},"alternate":{"type":"BlockStatement","body":[]}}]}, parser.parse("rly 1\nbut\nwow"), "Expected 'if(1) {} else {}'");
			});
			
			it("should parse if-elif statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"IfStatement","test":{"type":"Literal","value":1},"consequent":{"type":"BlockStatement","body":[]},"alternate":{"type":"IfStatement","test":{"type":"Literal","value":2},"consequent":{"type":"BlockStatement","body":[]},"alternate":null}}]}, parser.parse("rly 1\nbut rly 2\nwow"), "Expected 'if(1) {} else if (2) {}'");
			});
			
			it("should parse if-elif-else statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"IfStatement","test":{"type":"Literal","value":1},"consequent":{"type":"BlockStatement","body":[]},"alternate":{"type":"IfStatement","test":{"type":"Literal","value":2},"consequent":{"type":"BlockStatement","body":[]},"alternate":{"type":"BlockStatement","body":[]}}}]}, parser.parse("rly 1\nbut rly 2\nbut\nwow"), "Expected 'if(1) {} else if (2) {} else {}'");
			});
		});
		
		it("should parse while statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"WhileStatement","test":{"type":"Literal","value":1},"body":{"type":"BlockStatement","body":[]}}]}, parser.parse("many 1\nwow"), "Expected 'while(1) {}'");
		});
		
		describe("should parse for statement", function () {
			it("should parse for-expr statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ForStatement","init":null,"test":null,"update":null,"body":{"type":"BlockStatement","body":[]}}]}, parser.parse("much next next\nwow"), "Expected 'for(;;) {}'");
				
				assert.deepEqual({"type":"Program","body":[{"type":"ForStatement","init":{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"i"},"init":null}],"kind":"var"},"test":null,"update":null,"body":{"type":"BlockStatement","body":[]}}]}, parser.parse("much very i next next\nwow"), "Expected 'for(var i;;) {}'");
				
				assert.deepEqual({"type":"Program","body":[{"type":"ForStatement","init":{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"i"},"init":{"type":"Literal","value":0}}],"kind":"var"},"test":null,"update":null,"body":{"type":"BlockStatement","body":[]}}]}, parser.parse("much very i as 0 next next\nwow"), "Expected 'for(var i = 0;;) {}'");
			});
			
			it("should parse for-in statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ForInStatement","left":{"type":"Identifier","name":"i"},"right":{"type":"Literal","value":1},"body":{"type":"BlockStatement","body":[]}}]}, parser.parse("much i in 1\nwow"), "Expected 'for (i in 1) {}");
				
				assert.deepEqual({"type":"Program","body":[{"type":"ForInStatement","left":{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"i"},"init":null}],"kind":"var"},"right":{"type":"Literal","value":1},"body":{"type":"BlockStatement","body":[]}}]}, parser.parse("much very i in 1\nwow"), "Expected 'for (var i in 1) {}");
			});
		});
		
		describe("parses try statement", function () {
			it("should parse try-catch statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"TryStatement","block":{"type":"BlockStatement","body":[]},"handler":{"type":"CatchClause","param":{"type":"Identifier","name":"e"},"body":{"type":"BlockStatement","body":[]}},"finalizer":null}]}, parser.parse("try\ncatch e\nwow"), "Expected 'try{} catch(e){}'");
			});
			
			it("should parse try-finally statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"TryStatement","block":{"type":"BlockStatement","body":[]},"handler":null,"finalizer":{"type":"BlockStatement","body":[]}}]}, parser.parse("try\nretrieve\nwow"), "Expected 'try{} finally{}'");
			});
			
			it("should parse try-catch-finally statements", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"TryStatement","block":{"type":"BlockStatement","body":[]},"handler":{"type":"CatchClause","param":{"type":"Identifier","name":"e"},"body":{"type":"BlockStatement","body":[]}},"finalizer":{"type":"BlockStatement","body":[]}}]}, parser.parse("try\ncatch e\nretrieve\nwow"), "Expected 'try{}catch(e){}finally{}");
			});
		});
	});
});