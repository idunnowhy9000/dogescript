#!/usr/bin/env node

var fs	     = require('fs');
var path     = require('path');
var util     = require('util');
var stream   = require('stream');
var repl     = require('repl');
var argv     = require('optimist').usage('Usage: dogescript <file>').argv;

var parser   = require('../lib/parser');
var compile  = require('../lib/compile');

if (argv._[0]) {
	var file = fs.readFile(path.resolve(process.cwd(), argv._[0]), {encoding: 'utf-8'}, function (err, script) {
		var output = compile(parser.parse(script.toString()));

		process.stdout.write(output);
	});
} else {
	// streamy inheritance stuff
	// boilerblate from the docs
	function Stream () {
		stream.Transform.call(this);
	}
	util.inherits(Stream, stream.Transform);

	// see streams documentation
	Stream.prototype._transform = function (chunk, encoding, callback) {
		var script = compile(parser.parse(chunk.toString()));
		var lines  = script.split("\n");
		
		for (var i = 0; i < lines.length; i++) {
			// ignore empty lines
			if (lines[i] !== '') this.push(lines[i] + '\n');
		}
		
		callback();
	}

	var ds = new Stream();
	// pipe stdin through the dogescript translator to the repl
	repl.start({
		prompt : "DOGE> ",
		input  : ds,
		output : process.stdout
	});

	// begin streaming stdin to the dg translator and repl
	process.stdin.pipe(ds);
}