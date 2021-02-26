SMK - Simple Make
=================

Super simple wrapper-thing around `make` written in lua, for compiling projects written in c (or anything else you can cram into it if you really want to, like c++).

Usage:
======
======
smk uses `.smk` files to produce makefile-compatible files from short-hand descriptions of object/executable targets and their dependencies.
The smk files are formatted as follows: each line contains a target, specified by a name, followed by a colon and a list of dependencies.
The dependencies can either be source-files (`*.c`), header files (`*.h`, written in parentheses) or other targets (specified with a leading `$`).
Targets will by default generate object files. To specify executable targets, prepend the target name with `exec`.

Example smk file:
```
player: player.c (player.h)
game: game.c $player
```

To generate the makefile, run `smk your_smk_file.smk output.mk`. smk will also generate a default config.mk file (unless one already exists)
containing specifications of header directories, compiler flags, etc. An alternate config file name can also be specified as a final command-line argument.

The contents of the default config.mk file, an example smk file and its generated makefile can all be found in the repo.

Installation:
=============
=============
Requires a working lua installation (5.1+) and placement somewhere on a storage device of choice from where you can execute it.

Todo:
=====
=====
Customisation of build commands for bettter support of other languages, compilers, scripts, packaging formats, wrapping papers, condiments or secret herbs and spices.
