use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/set
use ../uses
use ./use-issue-analyzer

fn to-map-of-sets { |@arguments|
  lang:get-single-input $arguments |
    map:transform { |key value|
      put [$key (set:from $value)]
    }
}

fn should-emit-warnings { |&superfluous-uses=$true &dangling-identifiers=$true &missing-relative-uses=$true expected-warning-map|
  var source-code = (
    to-lines |
      slurp
  )

  var analyzer = (
    use-issue-analyzer:create &superfluous-uses=$superfluous-uses &dangling-identifiers=$dangling-identifiers &missing-relative-uses=$missing-relative-uses
  )

  var actual-warning-map = ($analyzer (src)[name] $source-code)

  if $expected-warning-map {
    put $actual-warning-map |
      to-map-of-sets |
      should-be (to-map-of-sets $expected-warning-map)
  } else {
    put $actual-warning-map |
      should-be $nil
  }
}

>> 'Elvish' {
  >> 'analyzers' {
    >> 'use issue analyzer' {
      >> 'when there are no warnings' {
        >> 'should emit $nil' {
          all [] |
            should-emit-warnings $nil
        }
      }

      >> 'should find superfluous uses' {
        all [
          'use str'
          'use github.com/giancosta86/velvet/v3/assertions'
          'use ../qualified-identifiers'
        ] |
          should-emit-warnings [
            &superfluous-uses=[
              [
                &line-number=1
                &reference=str
                &alias=$nil
                &namespace=str
                &kind=$uses:standard
              ]
              [
                &line-number=2
                &reference=github.com/giancosta86/velvet/v3/assertions
                &alias=$nil
                &namespace=assertions
                &kind=$uses:absolute
              ]
              [
                &line-number=3
                &reference=../qualified-identifiers
                &alias=$nil
                &namespace=qualified-identifiers
                &kind=$uses:relative
              ]
            ]
          ]
      }

      >> 'should find dangling identifiers' {
        all [
          'path:join X Y Z'
          'ro:sigma 95'
        ] |
          should-emit-warnings [
            &dangling-identifiers=[
              [
                &line-number=1
                &namespace=path
                &identifier=join
              ]
              [
                &line-number=2
                &namespace=ro
                &identifier=sigma
              ]
            ]
          ]
      }

      >> 'should find missing relative uses' {
        all [
          'use ./SOMETHING'
          'use ./SOMETHING-ELSE dodo'
          SOMETHING:f
          dodo:g
        ] |
          should-emit-warnings [
            &missing-relative-uses=[
              [
                &line-number=1
                &reference=./SOMETHING
                &alias=$nil
                &namespace=SOMETHING
                &kind=$uses:relative
              ]
              [
                &line-number=2
                &reference=./SOMETHING-ELSE
                &alias=dodo
                &namespace=dodo
                &kind=$uses:relative
              ]
          ]
        ]
      }

      >> 'in source code with all the issue kinds' {
        var lines-with-all-issues = [
          'use path'
          'use ./DODO'
          ''
          'cip:f 90'
        ]

        >> 'by default' {
          >> 'should find all issues at once' {
            all $lines-with-all-issues | should-emit-warnings [
              &superfluous-uses=[
                [
                  &line-number=1
                  &reference=path
                  &alias=$nil
                  &namespace=path
                  &kind=$uses:standard
                ]
                [
                  &line-number=2
                  &reference=./DODO
                  &alias=$nil
                  &namespace=DODO
                  &kind=$uses:relative
                ]
              ]
              &dangling-identifiers=[
                [
                  &line-number=4
                  &namespace=cip
                  &identifier=f
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
          }
        }

        >> 'when disabling only one flag' {
          all $lines-with-all-issues | should-emit-warnings &superfluous-uses=$false [
              &dangling-identifiers=[
                [
                  &line-number=4
                  &namespace=cip
                  &identifier=f
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
        }

        >> 'when disabling all flags' {
          >> 'should emit $nil' {
            all $lines-with-all-issues |
              should-emit-warnings &superfluous-uses=$false &dangling-identifiers=$false &missing-relative-uses=$false $nil
          }
        }
      }
    }
  }
}