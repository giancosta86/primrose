use str
use ./uses

>> 'Parsing the use declarations in Elvish code' {
  >> 'when parsing a standard import' {
    >> 'without alias' {
      uses:find-all 'use str' |
        should-be [
          &line-number=1
          &reference=str
          &alias=$nil
          &namespace=str
          &kind=$uses:standard
        ]
    }

    >> 'with alias' {
      put 'use str std-str' |
        uses:find-all |
        should-be [
          &line-number=1
          &reference=str
          &alias=std-str
          &namespace=std-str
          &kind=$uses:standard
        ]
    }
  }

  >> 'when parsing an absolute import' {
    >> 'without alias' {
      uses:find-all 'use github.com/giancosta86/primrose/test' |
        should-be [
          &line-number=1
          &reference=github.com/giancosta86/primrose/test
          &alias=$nil
          &namespace=test
          &kind=$uses:absolute
        ]
    }

    >> 'with alias' {
      uses:find-all 'use github.com/giancosta86/primrose/test my-test' |
        should-be [
          &line-number=1
          &reference=github.com/giancosta86/primrose/test
          &alias=my-test
          &namespace=my-test
          &kind=$uses:absolute
        ]
    }
  }

  >> 'when parsing a relative import' {
    >> 'without alias' {
      uses:find-all 'use ../../alpha/beta' |
        should-be [
          &line-number=1
          &reference=../../alpha/beta
          &alias=$nil
          &namespace=beta
          &kind=$uses:relative
        ]
    }

    >> 'with alias' {
      uses:find-all 'use ../../alpha/beta my-beta' |
        should-be [
          &line-number=1
          &reference=../../alpha/beta
          &alias=my-beta
          &namespace=my-beta
          &kind=$uses:relative
        ]
    }
  }

  >> 'when parsing multiple uses in the same source code' {
    var source-code = (
      all [
        'use str'
        'use str std-str'
        ''
        'use github.com/giancosta86/primrose/test'
        'use github.com/giancosta86/primrose/test my-test'
        ''
        'use ../../alpha/beta'
        'use ../../alpha/beta my-beta'
      ] |
        str:join "\n"
    )

    >> 'by default' {
      put $source-code |
        uses:find-all |
        should-emit [
          [
            &line-number=1
            &reference=str
            &alias=$nil
            &namespace=str
            &kind=$uses:standard
          ]
          [
            &line-number=2
            &reference=str
            &alias=std-str
            &namespace=std-str
            &kind=$uses:standard
          ]
          [
            &line-number=4
            &reference=github.com/giancosta86/primrose/test
            &alias=$nil
            &namespace=test
            &kind=$uses:absolute
          ]
          [
            &line-number=5
            &reference=github.com/giancosta86/primrose/test
            &alias=my-test
            &namespace=my-test
            &kind=$uses:absolute
          ]
          [
            &line-number=7
            &reference=../../alpha/beta
            &alias=$nil
            &namespace=beta
            &kind=$uses:relative
          ]
          [
            &line-number=8
            &reference=../../alpha/beta
            &alias=my-beta
            &namespace=my-beta
            &kind=$uses:relative
          ]
        ]
    }

    >> 'when requesting only absolute imports' {
      uses:find-all $source-code &kinds=[$uses:absolute] |
        should-emit [
          [
            &line-number=4
            &reference=github.com/giancosta86/primrose/test
            &alias=$nil
            &namespace=test
            &kind=$uses:absolute
          ]
          [
            &line-number=5
            &reference=github.com/giancosta86/primrose/test
            &alias=my-test
            &namespace=my-test
            &kind=$uses:absolute
          ]
        ]
    }
  }

  >> 'should skip comment lines' {
    uses:find-all '# use str' |
      should-emit []
  }
}
