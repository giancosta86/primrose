use path
use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use ../analysis/files
use ./analyzers/use-analyzer
use ./uses

#
# Analyzes all the Elvish scripts in the current directory tree, producing the text source of a diagram describing the `use` references for the inspected source files.
#
# It supports the following options:
#
# * `colors`: whether to add colors to the diagram. Disabled by default.
#
# * `format`: the output format; the command currently supports `graphviz` and `mermaid`.
#
# * `include-tests`: enable the inspection of **.test.elv** Velvet test files, too. Disabled by default.
#
# * `kinds`: the list of `use` declarations that must be taken into account when creating the diagram; all the kinds are included by default.
#
fn use-diagram { |&colors=$false &format=graphviz &include-tests=$false &kinds=[$uses:standard $uses:absolute $uses:relative]|
  var use-analyzer = (use-analyzer:create &kinds=$kinds)

  var provider-module = (
    lang:switch $format [
      &graphviz={ use-mod ./use-diagram/graphviz }
      &mermaid={ use-mod ./use-diagram/mermaid }
    ]
  )

  var diagram-printer = ($provider-module[create-diagram-printer~] &colors=$colors)

  $diagram-printer[start]

  fs:find-scripts &include-tests=$include-tests |
    files:analyze $use-analyzer |
    map:iterate { |source-path analyzer-result|
      var source-module _ = (fs:split-ext $source-path)

      all $analyzer-result[uses] | each { |use-declaration|
        var resolved-reference = (
          if (eq $use-declaration[kind] $uses:relative) {
            path:join (path:dir $source-module) $use-declaration[reference]
          } else {
            put $use-declaration[reference]
          }
        )

        var updated-use-declaration = (
          assoc $use-declaration resolved-reference $resolved-reference
        )

        $diagram-printer[on-use-declaration] $source-module $updated-use-declaration
      }
    }

  $diagram-printer[finish]
}
