# dogescript spec (3.0.0)

**dogescript** is a programming language made by [remixz](https://github.com/remixz) when he gone insane. **dogescript** is preferably named **dogescript** without uppercase letters.

Below is the official (unofficial), new specification of **dogescript**

## Files

dogescript files ends with the extension `.djs`. Should dogescript be ported to other languages, the `js` portion may be changed to reflect the new language. (dogeby => `.drb`)

## Notes

* dogescript uses single or double quotes for strings
* dogescript seperates statements by newlines or semicolons by default.
* dogescript blocks are like Javascript blocks (see [below](https://github.com/idunnowhy9000/dogescript/blob/master/LANGUAGE.md#blocks))

## dogescript syntax

### Expressions and operators

Expressions and operators work exactly like JS expressions and operators.

Several mapped operators have been introduced.

* `not` - `!==`
* `is` - `===`
* `and` - `&&`
* `or` - `||`
* `next` - `; `
* `as` - `=`
* `more` - `+=`
* `less` - `-=`
* `lots` - `*=`
* `few` - `/=`
* `bigger` - `>`
* `smaller` - `<`
* `biggerish` - `>=`
* `smallerish` - `<=`
* `shibeof` - `instanceof`
* `dogeof` - `typeof`

### Comments

dogescript supports single-line and multi-line comments.

Single-line comments starts with `shh` and ends on a new line.

```
shh This is a single-line comment
shh Everything to the end of it
shh is ignored.
```

Multiline comments starts with a `quiet` and ends with `loud`

```
quiet
  This is a multi-line comment
  Anything inside here is also
  ignored
loud
```

### Variable Declaration and Assignment

The syntax for declaration in dogescript is: `very`, followed by the variable's identifier, assignment operator (`=` or `as`), and an optional expression to initialize with.

```
very doge is 100                      shh Initialized variable
very shibe                            shh Uninitialized variable

shibe as 100                          shh Attribution
shibe = 100                           shh also supported
```

### Blocks

Blocks in dogescript are the same as blocks in Javascript, however ends with `wow`:

```
such block
	a = 1 + 1
wow
```

### Functions

#### Declaration

Function declarations starts with `such`, the function's name, with optional arguments separated by a whitespace.

All functions must have a `wow` statement. The syntax of it is `wow`, followed by an optional return parameter.

```
such sum much arg1, arg2
	shh Interior
wow arg1 + arg2
```

#### Calling

Function calls starts with `plz`, the function's name, with optional arguments separated by a colon.

```
plz sum with 1, 2
```

### Branching

#### If Statements

If Statements starts with `rly`, followed by an expression to test.

If Statements maybe followed by an Else Statement.

There are two types of Else Statements:

* "Else" Statements starts with `but`, then a block to call if If's expression failed
* "Else-if" Statements starts with `but`, then another if statement to call if the else's if expression failed and the "else-if" expression passed.

If Statement blocks must be ended by a `wow` statement.

```
very a is 3
very result

rly a smallerish 9
	result as "one"
but rly a smaller 10
	result as "two"
but rly number is 10
	result as "three"
but
	result as "four"
wow
```

### Loops

#### While Loops

While Loops starts with "many", an expression to test and a wow statement.

```
very i is 0
many woof smallerish 3
	shh Do something
	i is i + 1
wow
```

#### For Loops

For Loops starts with much, a lexical declaration and 2 expressions followed by next, a block and an empty wow statement.

```
shh doge style
much very i as 1 next i smaller 10 next i more 1
	rly i bigger 2
		shh Do something
	wow
wow
```

(is the same as this in Javascript)

```
for (var i = 1; i < 10; i += 1) {
	if (i < 2) {
		// Do something 
	}
}
```

### Trained Statement

The `trained` statement toggles `"use strict"` mode on the code, the statement translates directly to the Javascript string literal `"use strict"`.

### Bark Statement

The `bark` statement breaks out of the current block.

### Modules

#### Importing

The `so` statement imports a module using nodejs' `require` function.

So statements starts with `so`, and the module to be imported. This will translate to a variable with the module's name being the identifier.

```
so "hello"                      shh imports the module "hello"
so hello                        shh same
```

An additional `as` expression may be written. This will translate to a variable with the `as`'s identifier being the identifier.

```
so "hello" as h                 shh imports the module "hello" as the variable h
so "hello" as "h"               shh same as the above
```

#### Exporting

The `out` statement exports a module to `module.exports`. The `out` statement starts with `out`, and then the identifier, literal, etc... to be exported.

```
out a                          shh sets "module.exports" to identifier "a"
```

## "Built-in objects"

These are the list of "so-called" "Built-in objects". Identifiers may **not** use these names.

* `maybe`: `!+Math.random()`
* `console.loge`: `console.log`
* `dogeument`: `document`
* `windoge`: `window`