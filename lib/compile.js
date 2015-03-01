var esprima = require("esprima"),
	escodegen = require("escodegen"),
	estraverse = require("estraverse");

var JS_STATEMENT_TYPE = "X-JS-Statement",
	DSON_LITERAL = "X-DSON-LITERAL"
	CALL_EXPR_TYPE = "CallExpression",
	EXPR_STATEMENT_TYPE = "ExpressionStatement";

var DSON_FILE = "../lib/dson.js";

module.exports = function compile (ast) {
	// the post-preprocessor (love that name)
	var processed = ast, usingDSON = false;
	
	processed = estraverse.replace(processed, {
		enter: function (node) {
			// js statements
			if (node.type === JS_STATEMENT_TYPE) {
				// built ast tree
				var _ast = esprima.parse("{" + node.source + "}");
				
				// replace ast
				return _ast.body[0];
			}
			
			// dson literals
			if (node.type === DSON_LITERAL) {
				usingDSON = true;
				
				var _ast = esprima.parse("DSON.parse(" + JSON.stringify(node.source) + ")");
				return _ast.body[0];
			}
			
			// dson object manipulation
			if (node.name === "DSON") {
				usingDSON = true;
			}
		}
	});
	
	if (usingDSON) {
		processed.body.unshift(esprima.parse("if (!DSON) var DSON = require('" + DSON_FILE + "')"));
	}
	
	// return the modified ast tree
	return escodegen.generate(ast);
}