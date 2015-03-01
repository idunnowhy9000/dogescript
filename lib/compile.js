var escodegen = require("escodegen");

module.exports = function compile (ast) {
	return escodegen.generate(ast);
}