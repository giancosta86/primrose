use github.com/giancosta86/ethereal/v1/set
use ../uses

var -prologue = ^
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
    style="solid",
    fontname="Helvetica-Bold",
    penwidth=2
  ];
'

var -node-suffix-by-kind = [
  &$uses:standard=' [shape=hexagon, style=solid];'
  &$uses:absolute=' [shape=box, style="rounded,solid"];'
  &$uses:relative=';'
]

fn create-diagram-printer {
  var use-declarations = $set:empty
  var reference-pairs = []

  fn print-use-declarations {
    put $use-declarations |
      set:iterate { |use-declaration|
        echo '  "'$use-declaration[actual-reference]'"'$-node-suffix-by-kind[$use-declaration[kind]]
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
      echo $-prologue
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