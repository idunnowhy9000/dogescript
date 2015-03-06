var esprima = require("esprima"),
	escodegen = require("escodegen"),
	estraverse = require("estraverse");

var JS_STATEMENT_TYPE = "X-JS-Statement",
	DSON_LITERAL = "X-DSON-Literal",
	REQUIRE_STATEMENT = "X-Require-Statement",
	
	IDEN = "Identifier",
	MEMBER_EXPR = "MemberExpression";

var DSON_FILE = "../lib/dson.js";

module.exports = function compile (ast) {
	// the preprocessor
	var processed = ast, usingDSON = false, _ast;
	
	processed = estraverse.replace(processed, {
		enter: function (node) {
			// dson literals
			if (node.type === DSON_LITERAL) {
				usingDSON = true;
				
				_ast = esprima.parse("DSON.parse(" + JSON.stringify(node.source) + ")");
				return _ast.body[0];
			}
			
			if (node.type === IDEN) {
				// dson object manipulation
				if (node.name === "DSON") {
					usingDSON = true;
					return node;
				}
				
				// dogeument
				if (node.name === "dogeument") {
					var _node = node;
					_node.name = "document";
					return _node;
				}
				
				// windoge
				if (node.name === "windoge") {
					var _node = node;
					_node.name = "window";
					return _node;
				}
			}
			
			if (node.type === MEMBER_EXPR && node.object.name === "console" && node.property.name === "loge") {
				var _node = node;
				_node.property.name = "log";
				return _node;
			}
			
			// require statements
			if (node.type === REQUIRE_STATEMENT) {
				_ast = esprima.parse("var " + node.name + " = require(" + JSON.stringify(node.argument) + ")");
				return _ast.body[0];
			}
		}
	});
	
	if (usingDSON) {
		processed.body.unshift(esprima.parse("var DSON = require('" + DSON_FILE + "')"));
	}
	
	// return the modified ast tree
	return escodegen.generate(ast);
}