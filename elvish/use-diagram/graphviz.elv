use github.com/giancosta86/ethereal/v1/set
use ../uses
use ./shared

fn create-diagram-printer { |&colors=$false|
  var use-declarations = $set:empty
  var reference-pairs = $set:empty

  var node-suffix-by-kind = (
    if $colors {
      put [
        &$uses:standard=' [shape=hexagon, style=filled, fillcolor="'$shared:use-colors-by-class-name[standard]'"];'
        &$uses:absolute=' [shape=box, style="rounded,filled", fillcolor="'$shared:use-colors-by-class-name[absolute]'"];'
      ]
    } else {
      put [
        &$uses:standard=' [shape=hexagon, style=solid];'
        &$uses:absolute=' [shape=box, style=solid];'
      ]
    }
  )

  fn print-use-declarations-having-suffix {
    put $use-declarations |
      set:iterate { |use-declaration|
        var kind = $use-declaration[kind]

        if (has-key $node-suffix-by-kind $kind) {
          echo '  "'$use-declaration[resolved-reference]'"'$node-suffix-by-kind[$kind]
        }
      }
  }

  fn print-reference-pairs {
    put $reference-pairs |
      set:iterate { |reference-pair|
        var from to = (all $reference-pair)

        echo '  "'$from'" -> "'$to'";'
      }
  }

  put [
    &start={
      all [
        'digraph useDiagram {'
        '  rankdir=BT;'
        ''
        '  graph ['
        '    overlap=false,'
        '    splines=polyline,'
        '    nodesep=1.2,'
        '    ranksep=4,'
        '    pad="1,1"'
        '  ];'
        ''
        '  node ['
        '    shape=box,'
        '    style="filled",'
      ] |
        each $echo~

      if $colors {
        echo '    fillcolor="'$shared:use-colors-by-class-name[relative]'",'
      }

      all [
        '    fontname="Helvetica-Bold",'
        '    penwidth=2'
        '  ];'
      ] |
        each $echo~
    }

    &on-use-declaration={ |source-module use-declaration|
      set use-declarations = (set:add $use-declarations $use-declaration)

      var reference-pair = [$source-module $use-declaration[resolved-reference]]

      set reference-pairs = (set:add $reference-pairs $reference-pair)
    }

    &finish={
      print-use-declarations-having-suffix

      print-reference-pairs

      echo '}'
    }
  ]
}