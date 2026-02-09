use path
use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/map
use ../analysis/files
use ./analyzers/use-analyzer
use ./uses

#
# Analyzes all the Elvish scripts in the current directory tree, producing the text source of a use diagram based on Mermaid syntax.
#
# It supports the following flags:
#
# * `format`: the output format; the command currently supports `graphviz` and `mermaid`.
#
# * `include-tests`: enable checks for `.test.elv` files, too. Disabled by default.
#
# * `kinds`: the list of `use` declarations that must be taken into account when creating the diagram; all the kinds are included by default.
#
fn use-diagram { |&format=graphviz &include-tests=$false &kinds=[$uses:standard $uses:absolute $uses:relative]|
  var use-analyzer = (use-analyzer:create &kinds=$kinds)

  var provider-module = (
    if (eq $format graphviz) {
      use-mod ./use-diagram/graphviz
    } elif (eq $format mermaid) {
      use-mod ./use-diagram/mermaid
    } else {
      fail 'Unknown diagram format: '$format
    }
  )

  var diagram-printer = ($provider-module[create-diagram-printer~])

  $diagram-printer[start]

  fs:find-scripts &include-tests=$include-tests |
    files:analyze $use-analyzer |
    map:iterate { |source-path analyzer-result|
      var source-module _ = (fs:split-ext $source-path)

      all $analyzer-result[uses] | each { |use-declaration|
        var actual-reference = (
          if (eq $use-declaration[kind] $uses:relative) {
            path:join (path:dir $source-module) $use-declaration[reference]
          } else {
            put $use-declaration[reference]
          }
        )

        var updated-use-declaration = (
          assoc $use-declaration actual-reference $actual-reference
        )

        $diagram-printer[notify-use-declaration] $source-module $updated-use-declaration
      }
    }

  $diagram-printer[finish]
}
