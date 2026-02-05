use ./use-checker
use ./uses

var source-with-all-issues = (
  all [
    'use path'
    'use ./DODO'
    ''
    'cip:f 90'
  ] |
    to-lines |
    slurp
)

var expected-issues-in-file = [
  &superfluous-uses=[
    [
      &line-number=2
      &reference=./DODO
      &alias=$nil
      &namespace=DODO
      &kind=$uses:relative
    ]
    [
      &line-number=1
      &reference=path
      &alias=$nil
      &namespace=path
      &kind=$uses:standard
    ]
  ]
  &dangling-identifiers=[
    [
      &identifier=f
      &line-number=4
      &namespace=cip
    ]
  ]
  &missing-relative-uses=[
    [
      &line-number=2
      &reference=./DODO
      &alias=$nil
      &namespace=DODO
      &kind=$uses:relative
    ]
  ]
]

fn in-custom-temp-dir { |block|
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    echo $source-with-all-issues > source.elv

    echo $source-with-all-issues > source.test.elv

    $block | only-bytes
  }
}

>> 'Elvish use checker' {
  >> 'by default' {
    in-custom-temp-dir {
      var output-tester = (
        use-checker:check-uses |
          output-tester:create &unstyled
      )

      $output-tester[should-contain-all] [
        'source.elv:2: Missing relative use: : ./DODO'
        'source.elv:4: Dangling identifier: : cip:f'
        'source.elv:1: Superfluous use: : path'
        'source.elv:2: Superfluous use: : ./DODO'
      ]

      $output-tester[should-contain-none] [
        'source.test.elv'
      ]
    }
  }

  >> 'when including tests' {
    in-custom-temp-dir {
      var output-tester = (
        use-checker:check-uses &tests |
          output-tester:create &unstyled
      )

      $output-tester[should-contain-all] [
        'source.elv:2: Missing relative use: : ./DODO'
        'source.elv:4: Dangling identifier: : cip:f'
        'source.elv:1: Superfluous use: : path'
        'source.elv:2: Superfluous use: : ./DODO'
        'source.test.elv:2: Missing relative use: : ./DODO'
        'source.test.elv:4: Dangling identifier: : cip:f'
        'source.test.elv:1: Superfluous use: : path'
        'source.test.elv:2: Superfluous use: : ./DODO'
      ]
    }
  }

  >> 'when enabling raw input' {
    in-custom-temp-dir {
      use-checker:check-uses &tests &raw |
        should-be [
          &source.elv=$expected-issues-in-file
          &source.test.elv=$expected-issues-in-file
        ]
    }
  }
}