use path
use github.com/giancosta86/ethereal/v1/map
use ../analysis/files
use ./analyzers/use-analyzer
use ./uses

fn -standard-node { |reference|
  put $reference'{{'$reference'}}'
}

fn -absolute-node { |reference|
  put $reference'('$reference')'
}

fn -relative-node { |path|
  put $path'['$path']'
}

fn -use-node { |source-path use-declaration|
  var kind = $use-declaration[kind]
  var reference = $use-declaration[reference]

  if (eq $kind $uses:standard) {
    -standard-node $reference
  } elif (eq $kind $uses:absolute) {
    -absolute-node $reference
  } elif (eq $kind $uses:relative) {
    var referenced-path = (path:join (path:dir $source-path) $reference)
    -relative-node $referenced-path
  } else {
    fail 'Unknown node kind: '$kind
  }
}

fn -print-uses { |source-path uses|
  all $uses | each { |use-declaration|
    echo "\t"(-relative-node $source-path)' --> '(-use-node $source-path $use-declaration)
  }
}

fn get-mermaid { |&kinds=[$uses:standard $uses:absolute $uses:relative]|
  all [
    '---'
    'config:'
    '  layout: elk'
    '---'
    'flowchart BT'
  ] |
    each $echo~

  var use-analyzer = (use-analyzer:create &kinds=$kinds)

  all |
    files:analyze $use-analyzer |
    map:iterate { |source-path analyzer-result|
      -print-uses $source-path $analyzer-result[uses]
    }
}
