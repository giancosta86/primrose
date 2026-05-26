use ./use-checker
use ./uses

var source-with-all-issues = (
  all [
    'use ./DODO'
    ''
    'cip:f 90'
  ] |
    to-lines |
    slurp
)

var expected-issues = [
  &superfluous-uses=[
    [
      &line-number=1
      &reference=./DODO
      &alias=$nil
      &namespace=DODO
      &kind=$uses:relative
    ]
  ]
  &dangling-identifiers=[
    [
      &identifier=f
      &line-number=3
      &namespace=cip
    ]
  ]
  &missing-relative-uses=[
    [
      &line-number=1
      &reference=./DODO
      &alias=$nil
      &namespace=DODO
      &kind=$uses:relative
    ]
  ]
]

fn in-temp-dir-with-sources { |block|
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    echo $source-with-all-issues > source.elv

    echo $source-with-all-issues > source.test.elv

    $block | only-bytes
  }
}

>> 'Elvish use checker' {
  >> 'by default' {
    in-temp-dir-with-sources {
      var output = (
        capture {
          use-checker:check-uses
        }
      )

      put $output |
        should-contain-all [
          'source.elv:1: Missing relative use: ./DODO'
          'source.elv:3: Dangling identifier: cip:f'
          'source.elv:1: Superfluous use: ./DODO'
        ]

      put $output |
        should-contain-none [
          'source.test.elv'
        ]
    }
  }

  >> 'when including tests' {
    in-temp-dir-with-sources {
      capture {
        use-checker:check-uses &include-tests
      } |
        should-contain-all [
          'source.elv:1: Missing relative use: ./DODO'
          'source.elv:3: Dangling identifier: cip:f'
          'source.elv:1: Superfluous use: ./DODO'
          'source.test.elv:1: Missing relative use: ./DODO'
          'source.test.elv:3: Dangling identifier: cip:f'
          'source.test.elv:1: Superfluous use: ./DODO'
        ]
    }
  }

  >> 'when enabling raw input' {
    in-temp-dir-with-sources {
      use-checker:check-uses &include-tests &raw |
        should-be [
          &source.elv=$expected-issues
          &source.test.elv=$expected-issues
        ]
    }
  }
}