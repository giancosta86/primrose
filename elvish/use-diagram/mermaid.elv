use ../uses

fn -standard-node { |reference|
  put $reference'{{'$reference'}}'
}

fn -absolute-node { |reference|
  put $reference'('$reference')'
}

fn -relative-node { |reference|
  put $reference'['$reference']'
}

fn -node { |source-module use-declaration|
  var kind = $use-declaration[kind]

  if (eq $kind $uses:standard) {
    -standard-node $use-declaration[actual-reference]
  } elif (eq $kind $uses:absolute) {
    -absolute-node $use-declaration[actual-reference]
  } elif (eq $kind $uses:relative) {
    -relative-node $use-declaration[actual-reference]
  } else {
    fail 'Unknown node kind: '$kind
  }
}

fn create-diagram-printer {
  put [
    &start={
      all [
        '---'
        'config:'
        '  layout: elk'
        '  look: neo'
        '---'
        'flowchart BT'
      ] |
        each $echo~
    }

    &notify-use-declaration={ |source-module use-declaration|
      echo '  '(-relative-node $source-module)' --> '(-node $source-module $use-declaration)
    }

    &finish={ }
  ]
}
