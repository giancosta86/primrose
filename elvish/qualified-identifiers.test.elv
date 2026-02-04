use ./qualified-identifiers

>> 'Parsing qualified identifiers' {
  >> 'when parsing each identifier individually' {
    >> 'parsing a basic identifier' {
      qualified-identifiers:find-all 'alpha:beta' |
        should-be [
          &line-number=1
          &namespace=alpha
          &identifier=beta
        ]
    }

    >> 'parsing a callable identifier' {
      qualified-identifiers:find-all 'alpha:fi~' |
        should-be [
          &line-number=1
          &namespace=alpha
          &identifier=fi~
        ]
    }

    >> 'parsing a variable identifier' {
      qualified-identifiers:find-all '$alpha:my-var' |
        should-be [
          &line-number=1
          &namespace=alpha
          &identifier=my-var
        ]
    }

    >> 'parsing a multi-namespace identifier' {
      qualified-identifiers:find-all '$alpha:beta:gamma:delta' |
        should-be [
          &line-number=1
          &namespace=alpha
          &identifier=beta:gamma:delta
        ]
    }

    >> 'parsing a functional identifier between brackets' {
      qualified-identifiers:find-all '&reporters=[$cli:display~]' |
        should-be [
          &line-number=1
          &namespace=cli
          &identifier=display~
        ]
    }

    >> 'parsing a redirection merged with a scoped variable' {
      qualified-identifiers:find-all 'echo Test 2>$os:dev-null' |
        should-be [
          &line-number=1
          &namespace=os
          &identifier=dev-null
        ]
    }

    >> 'parsing a string with escaped \n' {
      >> 'should find no identifier' {
        qualified-identifiers:find-all 'Description:\nTest' |
          should-emit []
      }
    }

    >> 'parsing a colon between two variables' {
      >> 'should find no identifier' {
        qualified-identifiers:find-all "$alpha':'$beta" |
          should-emit []
      }
    }

    >> 'parsing a colon followed by a space' {
      >> 'should find no identifier' {
        qualified-identifiers:find-all 'Name: ' |
          should-emit []
      }
    }
  }

  >> 'parsing multiple qualified identifiers in the same source code' {
    all [
      'This is some sample string that should be a source code file.

      Colons followed by spaces like this: should not be parsed. Nor :a, :b or similar ones.

      * Basic identifier -> alpha:beta

      * Callable identifier -> (alpha:fi~)

      * (Variable identifier -> $alpha:my-var)

      * [Multi-namespace identifier -> $alpha:beta:gamma:delta)
      '
    ] |
      to-lines |
      slurp |
      qualified-identifiers:find-all (all) |
      should-emit [
        [
          &line-number=5
          &namespace=alpha
          &identifier=beta
        ]
        [
          &line-number=7
          &namespace=alpha
          &identifier=fi~
        ]
        [
          &line-number=9
          &namespace=alpha
          &identifier=my-var
        ]
        [
          &line-number=11
          &namespace=alpha
          &identifier=beta:gamma:delta
        ]
      ]
  }

  >> 'should skip comment lines' {
    qualified-identifiers:find-all '# alpha:beta' |
      should-emit [ ]
  }
}