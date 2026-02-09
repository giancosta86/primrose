use str
use ./use-diagram

>> 'Elvish use diagram' {
  tmp pwd = ..

  >> 'when requesting Graphviz format' {
    >> 'without colors' {
      var output-tester = (
        fs:find-scripts |
          use-diagram:use-diagram &format=graphviz |
          output-tester:create
      )

      $output-tester[should-contain-all] [
        'digraph useDiagram {'
        'rankdir=BT;'
        'splines=polyline'
        'node ['
        'shape=box'
        '"elvish/analyzers/use-issue-analyzer" -> "path"'
        '"analysis/text" -> "github.com/giancosta86/ethereal/v1/seq"'
        '"elvish/use-diagram/mermaid" -> "elvish/use-diagram/shared";'
      ]

      $output-tester[should-contain-none] [
        'fillcolor'
      ]
    }

    >> 'with colors' {
      var output-tester = (
        fs:find-scripts |
          use-diagram:use-diagram &colors &format=graphviz |
          output-tester:create
      )

      $output-tester[should-contain-all] [
        'digraph useDiagram {'
        'rankdir=BT;'
        'splines=polyline'
        'node ['
        'shape=box'
        '"elvish/analyzers/use-issue-analyzer" -> "path"'
        '"analysis/text" -> "github.com/giancosta86/ethereal/v1/seq"'
        '"elvish/use-diagram/mermaid" -> "elvish/use-diagram/shared";'
        'fillcolor'
      ]
    }
  }

  >> 'when requesting Mermaid format' {
    >> 'without colors' {
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

      $output-tester[should-contain-none] [
        'classDef standard fill:'
        'path:::standard'

        'classDef absolute fill:'
        'github.com/giancosta86/ethereal/v1/seq:::absolute'

        'classDef relative fill:'
        'analysis/files:::relative'
      ]
    }

    >> 'with colors' {
      var output-tester = (
        fs:find-scripts |
          use-diagram:use-diagram &colors &format=mermaid |
          output-tester:create
      )

      $output-tester[should-contain-all] [
        '  layout: elk'

        'flowchart BT'

        'elvish/use-diagram[elvish/use-diagram] --> path{{path}}'

        'elvish/use-diagram[elvish/use-diagram] --> github.com/giancosta86/ethereal/v1/map(github.com/giancosta86/ethereal/v1/map)'

        'elvish/use-diagram[elvish/use-diagram] --> analysis/files[analysis/files]'

        'classDef standard fill:'
        'path:::standard'

        'classDef absolute fill:'
        'github.com/giancosta86/ethereal/v1/seq:::absolute'

        'classDef relative fill:'
        'analysis/files:::relative'
      ]
    }
  }
}