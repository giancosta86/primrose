use github.com/giancosta86/ethereal/v1/set
use ../uses
use ./shared

fn -standard-node { |reference|
  put $reference'{{'$reference'}}'
}

fn -absolute-node { |reference|
  put $reference'('$reference')'
}

fn -relative-node { |reference|
  put $reference'['$reference']'
}

var -node-renderers-by-kind = [
  &$uses:standard=$-standard-node~
  &$uses:absolute=$-absolute-node~
  &$uses:relative=$-relative-node~
]

fn -node { |use-declaration|
  var kind = $use-declaration[kind]
  var node-renderer = $-node-renderers-by-kind[$kind]

  $node-renderer $use-declaration[resolved-reference]
}

fn -class { |class-name reference-set|
  echo

  echo '  'classDef $class-name 'fill:'$shared:use-colors-by-class-name[$class-name]

  set:iterate $reference-set { |reference|
    echo '  '$reference':::'$class-name
  }
}

fn create-diagram-printer { |&colors=$false|
  var mentioned-references = [
    &$uses:standard=$set:empty
    &$uses:absolute=$set:empty
    &$uses:relative=$set:empty
  ]

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

    &on-use-declaration={ |source-module use-declaration|
      if $colors {
        set mentioned-references[$uses:relative] = (
          set:add $mentioned-references[$uses:relative] $source-module
        )

        var kind = $use-declaration[kind]

        set mentioned-references[$kind] = (
          set:add $mentioned-references[$kind] $use-declaration[resolved-reference]
        )
      }

      echo '  '(-relative-node $source-module)' --> '(-node $use-declaration)
    }

    &finish={
      if $colors {
        -class standard $mentioned-references[$uses:standard]

        -class absolute $mentioned-references[$uses:absolute]

        -class relative $mentioned-references[$uses:relative]
      }
    }
  ]
}
