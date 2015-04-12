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
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":true}}]}, parser.parse('true'), "Expected identifier 'true'");
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":false}}]}, parser.parse('false'), "Expected identifier 'false'");
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
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"BinaryExpression","operator":"===","left":{"type":"Literal","value":1},"right":{"type":"Literal","value":1}}}]}, parser.parse("1 is 1"), "Expected 1 === 1");
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"BinaryExpression","operator":"!==","left":{"type":"Literal","value":1},"right":{"type":"Literal","value":1}}}]}, parser.parse("1 not 1"), "Expected 1 !== 1");
			});
			
			it("should do unary operators", function () {
				assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"UnaryExpression","operator":"-","argument":{"type":"Literal","value":5},"prefix":true}}]}, parser.parse("-5"), "Expected -5");
			});
		});
	});
	
	describe("parses statements", function () {
		it("parses variable declarations", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"a"},"init":null}],"kind":"var"}]}, parser.parse("very a"), "Expected 'var a'");
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"a"},"init":{"type":"Literal","value":5}}],"kind":"var"}]}, parser.parse("very a is 5"), "Expected 'var a = 5'");
			
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"a"},"init":null}],"kind":"const"}]}, parser.parse("always a"), "Expected 'const a'");
			assert.deepEqual({"type":"Program","body":[{"type":"VariableDeclaration","declarations":[{"type":"VariableDeclarator","id":{"type":"Identifier","name":"a"},"init":{"type":"Literal","value":5}}],"kind":"const"}]}, parser.parse("always a is 5"), "Expected 'const a = 5'");
		});
		
		// assignment: refer to parse expression
		
		it("parses wow statement", function () {
			// todo
		});
		
		it("parses trained statement", function () {
			assert.deepEqual({"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"Literal","value":"use strict"}}]}, parser.parse("trained"), "Expected 'use strict'");
		});
	});
});