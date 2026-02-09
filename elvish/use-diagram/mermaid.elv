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

fn -class { |class-name module-set fill|
  echo

  echo '  'classDef $class-name 'fill:'$fill

  set:iterate $module-set { |module|
    echo '  '$module':::'$class-name
  }
}

fn create-diagram-printer { |&colors=$false|
  var standard-modules = $set:empty
  var absolute-modules = $set:empty
  var relative-modules = $set:empty

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
      if $colors {
        set relative-modules = (set:add $relative-modules $source-module)

        if (eq $use-declaration[kind] $uses:standard) {
          set standard-modules = (set:add $standard-modules $use-declaration[actual-reference])
        } elif (eq $use-declaration[kind] $uses:absolute) {
          set absolute-modules = (set:add $absolute-modules $use-declaration[actual-reference])
        } elif (eq $use-declaration[kind] $uses:relative) {
          set relative-modules = (set:add $relative-modules $use-declaration[actual-reference])
        } else {
          fail 'Unknown use declaration kind: '$use-declaration[kind]
        }
      }

      echo '  '(-relative-node $source-module)' --> '(-node $source-module $use-declaration)
    }

    &finish={
      if $colors {
        -class standard $standard-modules $shared:standard-color

        -class absolute $absolute-modules $shared:absolute-color

        -class relative $relative-modules $shared:relative-color
      }
    }
  ]
}
