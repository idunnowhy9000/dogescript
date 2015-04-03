var esprima = require("esprima"),
	escodegen = require("escodegen"),
	estraverse = require("estraverse");

var IDEN = "Identifier",
	MEMBER_EXPR = "MemberExpression";

var DSON_FILE = "../lib/dson.js";

module.exports = function compile (ast) {
	// the preprocessor
	var processed = ast, usingDSON = false, _ast;
	
	processed = estraverse.replace(processed, {
		enter: function (node) {
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
		}
	});
	
	// return the modified ast tree
	return escodegen.generate(ast);
}