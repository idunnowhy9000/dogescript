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
var compile   = require("./lib/compile");

function parse (file, beauty) {
	var script = compile(file);

	if (beauty) return beautify(script)
	else return script;
}

module.exports = parse;