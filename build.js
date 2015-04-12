// Real programmers use vanilla js(tm)
var pegjs = require("pegjs"),
	fs = require("fs"),
	path = require("path");

var OPTIONS = {
	// dogescript
	"PEG_IN": "./src/dogescript/doge.pegjs",
	"PEG_OUT": "./lib/parser.js",
	
	// dson
	"DSON_PEG": "./src/dson/dson.pegjs",
	"DSON_START": "./src/dson/dson-start.js",
	"DSON_END": "./src/dson/dson-end.js",
	"DSON_OUT": "./lib/dson.js"
}

function read(file) {
	return fs.readFileSync(file, {"encoding": "utf8"});
}

function buildParser(file) {
	return pegjs.buildParser(read(file), {
		"output": "source"
	});
}

// dogescript
fs.writeFileSync(OPTIONS.PEG_OUT, "module.exports = " + buildParser(OPTIONS.PEG_IN) + ";\n");

// dson
fs.writeFileSync(OPTIONS.DSON_OUT, read(OPTIONS.DSON_START) + buildParser(OPTIONS.DSON_PEG) + read(OPTIONS.DSON_END));