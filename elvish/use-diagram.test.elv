use str
use ./use-diagram

>> 'Elvish use diagram' {
  >> 'should generate the expected output' {
    var output-tester = (
      put ../**.elv |
        keep-if { |source-path| not (str:has-suffix $source-path .test.elv) } |
        use-diagram:get-mermaid-source |
        output-tester:create
    )

    $output-tester[should-contain-all] [
      '  layout: elk'

      'flowchart BT'

      '../elvish/use-diagram.elv[../elvish/use-diagram.elv] --> path{{path}}'

      '../elvish/use-diagram.elv[../elvish/use-diagram.elv] --> github.com/giancosta86/ethereal/v1/map(github.com/giancosta86/ethereal/v1/map)'

      '../elvish/use-diagram.elv[../elvish/use-diagram.elv] --> ../analysis/files[../analysis/files]'
    ]
  }
}