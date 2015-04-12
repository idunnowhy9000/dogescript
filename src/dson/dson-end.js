;

var DSON = {};
DSON.parse = parser.parse;

DSON.dogeify = function dogeify(obj) {
	if (typeof obj === 'number') {
		return String(obj).replace(/e/i, "very");
	} else if (typeof obj === 'string') {
		return '"' + obj + '"';
	} else if (typeof obj === 'boolean') {
		return obj ? 'yes' : 'no';
	} else if (Array.isArray(obj)) {
		return obj.length < 1 ? 'so many' : 'so ' + obj.join(" and ") + ' much';
	} else if (typeof obj === 'object') {
		if (obj === null) {
			return 'empty';
		} else {
			var output, arr = [], val, key;
			
			for (val in obj) {
				key = obj[val];
				arr.push(' "' + val + '" is ' + dogeify(key));
			}
			
			output = 'such' + arr.join(", ") + ' wow';
			
			return output;
		}
	} else {
	}
};

module.exports = DSON;