var esprima = require("esprima"),
	escodegen = require("escodegen"),
	estraverse = require("estraverse");

var JS_STATEMENT_TYPE = "X-JS-Statement",
	DSON_LITERAL = "X-DSON-Literal",
	REQUIRE_STATEMENT = "X-Require-Statement",
	
	IDEN = "Identifier";

var DSON_FILE = "../lib/dson.js";

module.exports = function compile (ast) {
	// the post-preprocessor (love that name)
	var processed = ast, usingDSON = false, _ast;
	
	processed = estraverse.replace(processed, {
		enter: function (node) {
			// js statements
			if (node.type === JS_STATEMENT_TYPE) {
				// built ast tree
				_ast = esprima.parse("{" + node.source + "}");
				
				// replace ast
				return _ast.body[0];
			}
			
			// dson literals
			if (node.type === DSON_LITERAL) {
				usingDSON = true;
				
				_ast = esprima.parse("DSON.parse(" + JSON.stringify(node.source) + ")");
				return _ast.body[0];
			}
			
			// dson object manipulation
			if (node.type === IDEN && node.name === "DSON") {
				usingDSON = true;
			}
			
			// require statements
			if (node.type === REQUIRE_STATEMENT) {
				_ast = esprima.parse("var " + node.name + " = require(" + JSON.stringify(node.argument) + ")");
				return _ast.body[0];
			}
		}
	});
	
	if (usingDSON) {
		processed.body.unshift(esprima.parse("if (!DSON) var DSON = require('" + DSON_FILE + "')"));
	}
	
	// return the modified ast tree
	return escodegen.generate(ast);
}