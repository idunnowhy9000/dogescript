var esprima = require("esprima"),
	escodegen = require("escodegen");

var JS_STATEMENT_TYPE = "X-JS-Statement";

module.exports = function compile (ast) {
	// the post-preprocessor (love that name)
	var processed = ast;
	processed.body.forEach(function (node, index, array) {
		// parse js node
		if (node.type === JS_STATEMENT_TYPE) {
			// built ast tree
			var _ast = esprima.parse("{" + node.source + "}");
			
			// replace ast
			var block = _ast.body[0];
			array[index] = block;
		}
	});
	
	// return the modified ast tree
	return escodegen.generate(ast);
}