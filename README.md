![dogescript](doge.gif)

## dogescript 3

(aka when Zach went insane)

This is an implementation of the best new compile-to-JS language, dogescript. Wow.

Many things has been added in this implementation, such as, "native" DSON, new statements, expressions,..., and a rebuilt parser.

This is not affiliated with the official [dogescript orginization](https://github.com/dogescript) in any way.

All rights of dogescript goes to Zach a.k.a [remixz](https://github.com/remixz)

**Note that not everything works in this implementation**

```
    wow
         such dogescript
     very compiled
                  next-generation
       npm wow
```


### Installation

`npm install -g dogescript-3`

### Usage

#### Command Line

`dogescript-3` without a file launches a REPL.

`dogescript-3 location/to/dogescript.djs` pipes the result to stdout. Use a command like `dogescript-3 dogescript.djs > compiled.js` to save to a file.

#### Javascript

`dogescript(file)`
* `file` - A string of Dogescript.

### Language documentation

* Introduction to Dogescript - http://alexdantas.net/stuff/posts/introduction-to-dogescript/
* `LANGUAGE.md`

### Projects using dogescript

* [Doge Adventure!](https://github.com/ngscheurich/doge-adventure): A text adventure game inspired by [leonsumbitches](http://dailydoge.tumblr.com/post/21839788086/leonsumbitches-you-have-encountered-a-doge).
* [Doge Game of Life](https://github.com/eerwitt/doge-game-of-life): Conway's Game of Life in dogescript.
* [doge-toe](http://alexdantas.net/games/doge-toe/): Tic-Tac-Toe in dogescript.

### Utilities

#### Syntax highlighting

* [vim-dogescript](https://github.com/valeriangalliat/vim-dogescript): Vim highlighting.
* [dogescript-mode](https://github.com/alexdantas/dogescript-mode): Emacs highlighting.

#### Build plugins

* [dogeify](https://github.com/remixz/dogeify): A [Browserify](http://browserify.org/) transform for dogescript, also usable in [Gulp](https://github.com/gulpjs/gulp)
* [dogescript-loader](https://github.com/Bartvds/dogescript-loader): A [Webpack](https://Webpack.github.io) loader to bundle dogescript modules.
* [grunt-dogescript](https://github.com/Bartvds/grunt-dogescript): A [Grunt](http://gruntjs.com) plugin to compile dogescript (written in Dogescript!).
* [require-doge](https://github.com/Bartvds/require-doge): Directly require() dogescript .djs files in [node.js](http://www.nodejs.org).
* [lineman-dogescript](https://github.com/linemanjs/lineman-dogescript): A [Lineman](http://linemanjs.com/) plugin to compile dogescript.

### Contributors

The "original" [dogescript](https://github.com/dogescript/dogescript) has been made possible thanks to the contributions of many people. Thank you to everyone who has contributed in some way!

```bash
$ git log --format='%aN' | sort -u

Bart van der Schoor
Ben Atkin
Chad Engler
Chris Wheatley
Daniel Lockhart
Elan Shanker
Erik Erwitt
Jacob Groundwater
Joe Dailey
Johann Philipp Strathausen
Joseph Dailey
Nicholas Scheurich
Patrick Piemonte
Ray Toal
Zach Bruggeman
achesak
alehander42
dogejs
jasdev
noformnocontent
```