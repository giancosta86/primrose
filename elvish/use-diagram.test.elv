use str
use ./use-diagram

>> 'Elvish use diagram' {
  >> 'should generate the expected output' {
    tmp pwd = ..

    var output-tester = (
      fs:find-scripts |
        use-diagram:get-mermaid |
        output-tester:create
    )

    $output-tester[should-contain-all] [
      '  layout: elk'

      'flowchart BT'

      'elvish/use-diagram.elv[elvish/use-diagram.elv] --> path{{path}}'

      'elvish/use-diagram.elv[elvish/use-diagram.elv] --> github.com/giancosta86/ethereal/v1/map(github.com/giancosta86/ethereal/v1/map)'

      'elvish/use-diagram.elv[elvish/use-diagram.elv] --> analysis/files[analysis/files]'
    ]
  }
}