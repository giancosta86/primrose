# primrose

_Elegant file analysis in Elvish_

![Use diagram](use-diagram.svg)

**primrose** is a simple but _performant_ tool for analyzing file content in the [Elvish](https://elv.sh/) shell; in particular, it features:

- a general-purpose **analysis infrastructure**

- **analysis tool** for the Elvish language

- a **linter** for the `use` declaration, currently detecting:
  - superfluous uses

  - namespaces having no imports (_dangling references_)

  - relative imports pointing to inexistent files

## Installation

The library can be installed via **epm** - in particular:

```elvish
use epm

epm:install github.com/giancosta86/primrose
```

Even better, if you have [epm-plus](https://github.com/giancosta86/epm-plus), you can run:

```elvish
epm:install github.com/giancosta86/primrose@v1
```

or any other specific Git reference.

## Setup

In **rc.elv**, it is recommended to add the following lines:

```elvish
use github.com/giancosta86/velvet/velvet

var velvet~ = $velvet:velvet~
```

This will make the `velvet` command globally available at the command prompt.

## General-purpose analysis

The `analyze` function, residing in the `analysis/files` module, runs parallel analysis of source files - representing the very heart of the use analyzer; please, refer to its [source file](analysis/files.elv) for the documentation and, even more, to its [test suite](analysis/files.test.elv) for examples using it.

Similarly, the `line-by-line` function in the `analysis/text` module provides a valuable utility for analyzing text content.

## See also

- [Ethereal](https://github.com/giancosta86/ethereal) - _Elegant utilities for the Elvish shell_

- [Velvet](https://github.com/giancosta86/velvet) - _Smooth, functional testing in the Elvish shell_

- [epm-plus](https://github.com/giancosta86/epm-plus) - _Package versioning for epm in Elvish_

- [Elvish](https://elv.sh/)
