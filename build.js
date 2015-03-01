var pegjs = require("pegjs"),
	fs = require("fs"),
	path = require("path");

var OPTIONS = {
	"PEG_FILE": "./src/doge.pegjs",
	"PEG_OUT": "./lib/doge.js"
}

var pegfile = pegjs.buildParser(fs.readFileSync(path.join(__dirname,OPTIONS.PEG_FILE), "utf8"), {
	"output": "source"
});

fs.writeFileSync(path.join(__dirname,OPTIONS.PEG_OUT), pegfile, {"encoding": "utf8"});