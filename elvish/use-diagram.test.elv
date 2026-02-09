use str
use ./use-diagram

>> 'Elvish use diagram' {
  >> 'when requesting Mermaid format' {
    tmp pwd = ..

    var output-tester = (
      fs:find-scripts |
        use-diagram:use-diagram &format=mermaid |
        output-tester:create
    )

    $output-tester[should-contain-all] [
      '  layout: elk'

      'flowchart BT'

      'elvish/use-diagram[elvish/use-diagram] --> path{{path}}'

      'elvish/use-diagram[elvish/use-diagram] --> github.com/giancosta86/ethereal/v1/map(github.com/giancosta86/ethereal/v1/map)'

      'elvish/use-diagram[elvish/use-diagram] --> analysis/files[analysis/files]'
    ]
  }
}