use github.com/giancosta86/ethereal/v1/set
use ../uses
use ./shared

fn create-diagram-printer { |&colors=$false|
  var use-declarations = $set:empty
  var reference-pairs = []

  var node-suffix-by-kind = (
    if $colors {
      put [
        &$uses:standard=' [shape=hexagon, style=filled, fillcolor="'$shared:standard-color'"];'
        &$uses:absolute=' [shape=box, style="rounded,filled", fillcolor="'$shared:absolute-color'"];'
      ]
    } else {
      put [
        &$uses:standard=' [shape=hexagon, style=solid];'
        &$uses:absolute=' [shape=box, style=solid];'
      ]
    }
  )


  fn print-use-declarations {
    put $use-declarations |
      set:iterate { |use-declaration|
        if (has-key $node-suffix-by-kind $use-declaration[kind]) {
          echo '  "'$use-declaration[actual-reference]'"'$node-suffix-by-kind[$use-declaration[kind]]
        }
      }
  }

  fn print-reference-pairs {
    all $reference-pairs | each { |reference-pair|
      var from to = (all $reference-pair)

      echo '  "'$from'" -> "'$to'";'
    }
  }

  put [
    &start={
      var prologue = ^
        'digraph useDiagram {
          rankdir=BT;

          graph [
            overlap=false,
            splines=polyline,
            nodesep=1.2,
            ranksep=4,
            pad="1,1"
          ];

          node [
            shape=box,
            style="filled",
            '(if $colors { echo 'fillcolor="'$shared:relative-color'",' } else { echo '' })'
            fontname="Helvetica-Bold",
            penwidth=2
          ];
        '

      echo $prologue
    }

    &notify-use-declaration={ |source-module use-declaration|
      set use-declarations = (set:add $use-declarations $use-declaration)

      set reference-pairs = (conj $reference-pairs [$source-module $use-declaration[actual-reference]])
    }

    &finish={
      print-use-declarations

      print-reference-pairs

      echo '}'
    }
  ]
}