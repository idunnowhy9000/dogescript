var escodegen = require("escodegen"),
	estraverse = require("estraverse");

var IDEN = "Identifier",
	MEMBER_EXPR = "MemberExpression";

var DSON_FILE = "../lib/dson.js";

module.exports = function compile (ast) {
	estraverse.replace(ast, {
		enter: function (node) {
			if (node.type === IDEN) {
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