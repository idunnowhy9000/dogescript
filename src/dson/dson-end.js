;

var DSON = {};
DSON.parse = parser.parse;

DSON.dogeify = function dogeify(obj) {
	var output = 'such';

	if (typeof obj !== 'object' || obj.length > -1) {
		throw 'Error: Must pass an object to dogeify';
	}

	for (var key in obj) {
		var val = obj[key];

		var type = typeof val;

		if (type === 'object' && val.length > -1) {
			output += ' "' + key + '" is so ';
			for (var i = 0; i < val.length; i++) {
				if (i === val.length - 1) {
					output += ' and ';
				} else if (i !== 0) {
					output += ' also ';
				}

				output += '"' + val[i] + '"';
			}
			output += ' many';
		} else if (type === 'object') {
			if (key === null) output += ' "' + key + '" is empty';
			else output += ' "' + key + '" is ' + dogeify(val);
		} else if (type === 'number') {
			output += ' "' + key + '" is ' + val.toString(8) + '';
		} else if (type === 'string') {
			output += ' "' + key + '" is "' + val + '"';
		} else if (type === 'boolean') {
			output += ' "' + key + '" is ';
			if (val === true) {
				output += 'yes';
			} else {
				output += 'no';
			}
		} else {
			output += ' "' + key + '" is "' + val.toString() + '"';
		}

		output += ',';
	}

	output = output.replace(/,$/, '');
	output += ' wow';
	return output;
};

module.exports = DSON;