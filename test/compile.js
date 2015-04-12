var assert = require("assert"),
	compile = require('../lib/compile.js'),
	parser = require('../lib/parser.js');

describe("Compiler", function () {
	it("should compile", function () {
		assert.equal("hello.world('wut');", compile(parser.parse("plz hello.world with 'wut'")), "Expected hello.world('wut')");
	});
	
	it("should replace identifiers", function () {
		assert.equal("document;", compile(parser.parse("dogeument")), "Expected document");
		assert.equal("window;", compile(parser.parse("windoge")), "Expected window");
		assert.equal("console.log;", compile(parser.parse("console.loge")), "Expected console.log");
	});
});