# primrose

_Elegant file analysis in Elvish_

![Use diagram](docs/use-diagram.svg)

**primrose** is a simple but _performant_ library for analyzing file content in the [Elvish](https://elv.sh/) shell; in particular, it features:

- a general-purpose **analysis infrastructure**

- _regex-based_ **analysis functions** for the **Elvish** language

- a **linter** for `use` declarations in **Elvish**, currently detecting:
  - **superfluous uses**

  - namespaces having no imports (**dangling references**)

  - **relative imports** pointing to _inexistent files_

* a **dependency diagram generator** for **Elvish**, emitting the source code of a [Mermaid](https://mermaid.ai/) flowchart.

The _overall architecture_ can be summarized as follows:

![Architecture](docs/architecture.svg)

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

## Command-line tools

### Usage checker

To make it available, it is recommended to add the following lines to **rc.elv**:

```elvish
use github.com/giancosta86/primrose/v1/elvish/use-checker

var check-uses~ = $use-checker:check-uses~
```

This will make the `check-uses` command globally available at the command prompt.

Then, in your project directory, just run

```elvish
check-uses
```

The command also supports more options - please, refer to the [module](elvish/use-checker.elv) documentation for details.

### Diagram generator

To make it available, it is recommended to add the following lines to **rc.elv**:

```elvish
use github.com/giancosta86/primrose/v1/elvish/use-diagram

var use-diagram~ = $use-diagram:get-mermaid~
```

This will make the `use-diagram` command globally available at the command prompt.

Then, in your project directory, just run

```elvish
use-diagram
```

The generated output can be procesed by tools supporting the selected syntax - in particular, the `dot` command for [Graphviz](https://graphviz.org/), as well as Mermaid's [playground](https://mermaid.ai/play) or [command-line tool](https://www.npmjs.com/package/@mermaid-js/mermaid-cli).

For example, in the case of Graphviz:

```elvish
use-diagram &colors | dot -Tsvg -o use-diagram.svg
```

The command also supports more options - please, refer to the [module](elvish/use-diagram.elv) documentation for details.

## Elvish source analysis core

The most important modules for analyzing source files - and the very heart of the related command-line tools - are:

- [qualified-identifiers](elvish/qualified-identifiers.elv)

- [uses](elvish/uses.elv)

## General-purpose analysis

The `analyze` function, residing in the `analysis/files` module, runs **parallel analysis** of source files - representing the very heart of the entire library; please, refer to its [source file](analysis/files.elv) for the documentation and, even more, to its [test suite](analysis/files.test.elv) for examples using it.

Similarly, the `line-by-line` function in the `analysis/text` module provides a valuable utility for analyzing text content.

## See also

- [Ethereal](https://github.com/giancosta86/ethereal) - _Elegant utilities for the Elvish shell_

- [Velvet](https://github.com/giancosta86/velvet) - _Smooth, functional testing in the Elvish shell_

- [epm-plus](https://github.com/giancosta86/epm-plus) - _Package versioning for epm in Elvish_

- [Graphviz](https://graphviz.org/) - _Open source graph visualization software_

- [Mermaid](https://mermaid.ai/) - _Faster, smarter diagramming for teams —
  with markdown-style code and AI_

- [Elvish](https://elv.sh/)
