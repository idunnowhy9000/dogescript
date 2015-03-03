/**
 * dogescript - wow so syntax such language
 *
 * Copyright (c) 2013-2014 Zach Bruggeman
 *
 * dogescript is licensed under the MIT License.
 *
 * @package dogescript
 * @author  Zach Bruggeman <talkto@zachbruggeman.me>
 */

var beautify = require('js-beautify').js_beautify;
var xhr	     = require('xhr');
var compile  = require("./lib/compile");
var parser   = require("./lib/parser");

module.exports = function parse (file, beauty) {
	var script = compile(parser.parse(file));

	if (beauty) return beautify(script)
	else return script;
};