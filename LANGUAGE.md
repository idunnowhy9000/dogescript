# dogescript spec (2.4.0)

**dogescript** is a programming language made by [remixz](https://github.com/remixz) when he gone insane. **dogescript** is preferably named **dogescript** without uppercase letters.

Below is the official (unofficial), new specification of **dogescript**

## Files

dogescript files ends with the extension `.djs`. Should dogescript be ported to other languages, the `js` portion may be changed to reflect the new language. (dogeby => `.drb`)

## Notes

* dogescript uses single or double quotes for strings
* dogescript seperates statements by newlines or semicolons by default.

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

### Embedded Javascript

**Not present in this implementation**

Javascript **statements** may be embedded directly into dogescript. To embed Javascript, start with `@"` or `@'`, the Javascript code and end with `"` or `'` like strings.

Embedded Javascript is a method to fill in the holes that dogescript doesn't fill (think of it like "polyfilling" languages).

```
@"console.log('this is embedded javascript');"
```

### Variable Declaration and Assignment

The syntax for declaration in dogescript is: `very`, followed by the variable's identifier, assignment operator (`=` or `is`), and an optional expression to initialize with.

```
very doge is 100                      shh Initialized variable
very shibe                            shh Uninitialized variable

shibe as 100                          shh Attribution
shibe = 100                           shh also supported
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

Function calls starts with `plz`, the function's name, with optional arguments separated by a whitespace.

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

To be added.

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
so hello                        shh also imports the module "hello"
```

An additional `as` expression may be written. This will translate to a variable with the `as`'s identifier being the identifier.

```
so "hello" as h                 shh imports the module "hello" as the variable h
```

#### Exporting

**Not (yet) present in this implementation**

The `out` statement exports a module to `module.exports`

## "Built-in objects"

These are the list of "so-called" "Built-in objects". Identifiers may **not** use these names.

* `maybe`: `!+Math.random()`
* `console.loge`: `console.log`
* `dogeument`: `document`
* `windoge`: `window`