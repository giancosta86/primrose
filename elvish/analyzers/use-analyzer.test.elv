use github.com/giancosta86/ethereal/v1/seq
use ../uses
use ./use-analyzer

var test-source-code = ^
'use str
use os standard-os
use path

use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/velvet/v3/assertions v-a

use ./alpha
use ../beta bt'

var expected-standard-uses = [
  [
    &line-number=1
    &reference=str
    &alias=$nil
    &namespace=str
    &kind=$uses:standard
  ]
  [
    &line-number=2
    &reference=os
    &alias=standard-os
    &namespace=standard-os
    &kind=$uses:standard
  ]
  [
    &line-number=3
    &reference=path
    &alias=$nil
    &namespace=path
    &kind=$uses:standard
  ]
]

var expected-absolute-uses = [
  [
    &line-number=5
    &reference=github.com/giancosta86/ethereal/v1/map
    &alias=$nil
    &namespace=map
    &kind=$uses:absolute
  ]
  [
    &line-number=6
    &reference=github.com/giancosta86/velvet/v3/assertions
    &alias=v-a
    &namespace=v-a
    &kind=$uses:absolute
  ]
]

var expected-relative-uses = [
  [
    &line-number=8
    &reference=./alpha
    &alias=$nil
    &namespace=alpha
    &kind=$uses:relative
  ]
  [
    &line-number=9
    &reference=../beta
    &alias=bt
    &namespace=bt
    &kind=R
  ]
]

fn expect-uses { |&kinds=$nil expected-uses|
  var use-analyzer = (
    if $kinds {
      use-analyzer:create &kinds=$kinds
    } else {
      use-analyzer:create
    }
  )

  var actual-result-map = ($use-analyzer (src)[name] $test-source-code)

  if (seq:is-non-empty $expected-uses) {
    put $actual-result-map |
      should-be [
        &uses=$expected-uses
      ]
  } else {
    put $actual-result-map |
      should-be $nil
  }
}

>> 'Elvish analyzers' {
  >> 'use analyzer' {
    >> 'by default' {
      >> 'should report all the uses' {
        expect-uses [
          $@expected-standard-uses
          $@expected-absolute-uses
          $@expected-relative-uses
        ]
      }
    }

    >> 'when requesting just a specific kind of uses' {
      expect-uses &kinds=[$uses:standard] $expected-standard-uses
    }

    >> 'when requesting a set of kind of uses' {
      expect-uses &kinds=[$uses:standard $uses:relative] [
        $@expected-standard-uses
        $@expected-relative-uses
      ]
    }

    >> 'when requesting no uses' {
      expect-uses &kinds=[] []
    }
  }
}