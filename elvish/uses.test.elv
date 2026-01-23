use str
use ./uses

fn -parse-single-use { |code|
  var parsed-uses = [(uses:find-all $code)]

  if (> (count $parsed-uses) 1) {
    fail 'The test code snippet must contain only one "use" declaration!'
  }

  put $parsed-uses[0]
}

>> 'Parsing the use declarations in Elvish code' {
  >> 'when parsing a standard import' {
    >> 'without alias' {
      var parsed-use = (-parse-single-use 'use str')

      >> 'should have the usual reference' {
        put $parsed-use[reference] |
          should-be str
      }

      >> 'should have no alias' {
        put $parsed-use[alias] |
          should-be $nil
      }

      >> 'should have namespace given by its reference' {
        put $parsed-use[namespace] |
          should-be str
      }

      >> 'should be of standard kind' {
        put $parsed-use[kind] |
          should-be $uses:standard
      }

      >> 'should be on the expected line' {
        put $parsed-use[line-number] |
          should-be 1
      }
    }

    >> 'with alias' {
      var parsed-use = (-parse-single-use 'use str std-str')

      >> 'should have the usual reference' {
        put $parsed-use[reference] |
          should-be str
      }

      >> 'should have the declared alias' {
        put $parsed-use[alias] |
          should-be std-str
      }

      >> 'should have namespace equal to its alias' {
        put $parsed-use[namespace] |
          should-be std-str
      }

      >> 'should be of standard kind' {
        put $parsed-use[kind] |
          should-be $uses:standard
      }

      >> 'should be on the expected line' {
        put $parsed-use[line-number] |
          should-be 1
      }
    }
  }

  >> 'when parsing an absolute import' {
    >> 'without alias' {
      var parsed-use = (-parse-single-use 'use github.com/giancosta86/primrose/test')

      >> 'should have the given reference' {
        put $parsed-use[reference] |
          should-be github.com/giancosta86/primrose/test
      }

      >> 'should have no alias' {
        put $parsed-use[alias] |
          should-be $nil
      }

      >> 'should have namespace given by the last component of its reference' {
        put $parsed-use[namespace] |
          should-be test
      }

      >> 'should be of absolute kind' {
        put $parsed-use[kind] |
          should-be $uses:absolute
      }

      >> 'should be on the expected line' {
        put $parsed-use[line-number] |
          should-be 1
      }
    }

    >> 'with alias' {
      var parsed-use = (-parse-single-use 'use github.com/giancosta86/primrose/test my-test')

      >> 'should have the given reference' {
        put $parsed-use[reference] |
          should-be github.com/giancosta86/primrose/test
      }

      >> 'should have the declared alias' {
        put $parsed-use[alias] |
          should-be my-test
      }

      >> 'should have namespace equal to its alias' {
        put $parsed-use[namespace] |
          should-be my-test
      }

      >> 'should be of absolute kind' {
        put $parsed-use[kind] |
          should-be $uses:absolute
      }

      >> 'should be on the expected line' {
        put $parsed-use[line-number] |
          should-be 1
      }
    }
  }

  >> 'when parsing a relative import' {
    >> 'without alias' {
      var parsed-use = (-parse-single-use 'use ../../alpha/beta')

      >> 'should have the given reference' {
        put $parsed-use[reference] |
          should-be ../../alpha/beta
      }

      >> 'should have no alias' {
        put $parsed-use[alias] |
          should-be $nil
      }

      >> 'should have namespace given by the last component of its reference' {
        put $parsed-use[namespace] |
          should-be beta
      }

      >> 'should be of relative kind' {
        put $parsed-use[kind] |
          should-be $uses:relative
      }

      >> 'should be on the expected line' {
        put $parsed-use[line-number] |
          should-be 1
      }
    }

    >> 'with alias' {
      var parsed-use = (-parse-single-use 'use ../../alpha/beta my-beta')

      >> 'should have the given reference' {
        put $parsed-use[reference] |
          should-be ../../alpha/beta
      }

      >> 'should have the declared alias' {
        put $parsed-use[alias] |
          should-be my-beta
      }

      >> 'should have namespace equal to its alias' {
        put $parsed-use[namespace] |
          should-be my-beta
      }

      >> 'should be of relative kind' {
        put $parsed-use[kind] |
          should-be $uses:relative
      }

      >> 'should be on the expected line' {
        put $parsed-use[line-number] |
          should-be 1
      }
    }
  }

  >> 'when parsing multiple uses in the same source code' {
    var source-code = (
      all [
        'use str'
        'use str std-str'
        'use github.com/giancosta86/primrose/test'
        'use github.com/giancosta86/primrose/test my-test'
        'use ../../alpha/beta'
        'use ../../alpha/beta my-beta'
      ] |
        str:join "\n"
    )

    >> 'by default' {
      var parsed-uses = [(uses:find-all $source-code)]

      >> 'should parse them all' {
        count $parsed-uses |
          should-be 6
      }

      >> 'should parse the standard import' {
        put $parsed-uses[0] |
          should-be [
            &line-number=1
            &reference=str
            &alias=$nil
            &namespace=str
            &kind=$uses:standard
          ]
      }

      >> 'should parse the aliased standard import' {
        put $parsed-uses[1] |
          should-be [
            &line-number=2
            &reference=str
            &alias=std-str
            &namespace=std-str
            &kind=$uses:standard
          ]
      }

      >> 'should parse the absolute import' {
        put $parsed-uses[2] |
          should-be [
            &line-number=3
            &reference=github.com/giancosta86/primrose/test
            &alias=$nil
            &namespace=test
            &kind=$uses:absolute
          ]
      }

      >> 'should parse the aliased absolute import' {
        put $parsed-uses[3] |
          should-be [
            &line-number=4
            &reference=github.com/giancosta86/primrose/test
            &alias=my-test
            &namespace=my-test
            &kind=$uses:absolute
          ]
      }

      >> 'should parse the relative import' {
        put $parsed-uses[4] |
          should-be [
            &line-number=5
            &reference=../../alpha/beta
            &alias=$nil
            &namespace=beta
            &kind=$uses:relative
          ]
      }

      >> 'should parse the aliased relative import' {
        put $parsed-uses[5] |
          should-be [
            &line-number=6
            &reference=../../alpha/beta
            &alias=my-beta
            &namespace=my-beta
            &kind=$uses:relative
          ]
      }
    }

    >> 'when requesting only absolute imports' {
      uses:find-all $source-code &kinds=[$uses:absolute] |
        should-emit [
          [
            &line-number=3
            &reference=github.com/giancosta86/primrose/test
            &alias=$nil
            &namespace=test
            &kind=$uses:absolute
          ]
          [
            &line-number=4
            &reference=github.com/giancosta86/primrose/test
            &alias=my-test
            &namespace=my-test
            &kind=$uses:absolute
          ]
        ]
    }
  }
}
