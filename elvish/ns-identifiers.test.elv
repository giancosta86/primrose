use ./ns-identifiers

>> 'Parsing namespaced identifiers' {
  >> 'when parsing each identifier individually' {
    >> 'parsing a basic identifier' {
      ns-identifiers:find-all 'alpha:beta' |
        should-emit [
          [
            &line-number=1
            &namespace=alpha
            &identifier=beta
          ]
        ]
    }

    >> 'parsing a callable identifier' {
      ns-identifiers:find-all 'alpha:fi~' |
        should-emit [
          [
            &line-number=1
            &namespace=alpha
            &identifier=fi~
          ]
        ]
    }

    >> 'parsing a variable identifier' {
      ns-identifiers:find-all '$alpha:my-var' |
        should-emit [
          [
            &line-number=1
            &namespace=alpha
            &identifier=my-var
          ]
        ]
    }

    >> 'parsing a multi-namespace identifier' {
      ns-identifiers:find-all '$alpha:beta:gamma:delta' |
        should-emit [
          [
            &line-number=1
            &namespace=alpha
            &identifier=beta:gamma:delta
          ]
        ]
    }

    >> 'parsing a functional identifier between brackets' {
      ns-identifiers:find-all '&reporters=[$cli:display~]' |
        should-emit [
          [
            &line-number=1
            &namespace=cli
            &identifier=display~
          ]
        ]
    }

    >> 'parsing a redirection merged with a scoped variable' {
      ns-identifiers:find-all 'echo Test 2>$os:dev-null' |
        should-be [
          &line-number=1
          &namespace=os
          &identifier=dev-null
        ]
    }

    >> 'parsing a string with escaped \n' {
      >> 'should find no identifier' {
        ns-identifiers:find-all 'Description:\nTest' |
          count |
          should-be 0
      }
    }

    >> 'parsing a colon between two variables' {
      >> 'should find no identifier' {
        ns-identifiers:find-all "$alpha':'$beta" |
          count |
          should-be 0
      }
    }

    >> 'parsing a colon followed by a space' {
      >> 'should find no identifier' {
        ns-identifiers:find-all 'Name: ' |
          count |
          should-be 0
      }
    }
  }

  >> 'when parsing multiple namespaced identifiers in the same source code' {
    var parsed-identifiers = [(
      ns-identifiers:find-all 'This is some sample string that should be a source code file.

      Colons followed by spaces like this: should not be parsed. Nor :a, :b or similar ones.

      * Basic identifier -> alpha:beta

      * Callable identifier -> (alpha:fi~)

      * (Variable identifier -> $alpha:my-var)

      * [Multi-namespace identifier -> $alpha:beta:gamma:delta)
      '
    )]

    >> 'should parse them all' {
      count $parsed-identifiers |
        should-be 4
    }

    >> 'should parse a basic identifier' {
      put $parsed-identifiers[0] |
        should-be [
          &line-number=5
          &namespace=alpha
          &identifier=beta
        ]
    }

    >> 'should parse a callable identifier' {
      put $parsed-identifiers[1] |
        should-be [
          &line-number=7
          &namespace=alpha
          &identifier=fi~
        ]
    }

    >> 'should parse a variable identifier' {
      put $parsed-identifiers[2] |
        should-be [
          &line-number=9
          &namespace=alpha
          &identifier=my-var
        ]
    }

    >> 'should parse a multi-namespace identifier' {
      put $parsed-identifiers[3] |
        should-be [
          &line-number=11
          &namespace=alpha
          &identifier=beta:gamma:delta
        ]
    }
  }
}