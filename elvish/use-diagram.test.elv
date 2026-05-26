use str
use ./use-diagram
use ./use-diagram/shared

>> 'Elvish use diagram' {
  tmp pwd = ..

  >> 'when requesting Graphviz format' {
    var always-displayed-lines = [
      'digraph useDiagram {'
      'rankdir=BT;'
      'splines=polyline'
      'node ['
      'shape=box'
      '"elvish/analyzers/use-issue-analyzer" -> "path"'
      '"analysis/text" -> "github.com/giancosta86/ethereal/v1/seq"'
      '"elvish/use-diagram/mermaid" -> "elvish/use-diagram/shared";'
    ]

    var color-lines = [
      (printf 'fillcolor="%s"' $shared:use-colors-by-class-name[relative])
      (printf '"re" [shape=hexagon, style=filled, fillcolor="%s"];' $shared:use-colors-by-class-name[standard])
      (printf '"github.com/giancosta86/ethereal/v1/map" [shape=box, style="rounded,filled", fillcolor="%s"];' $shared:use-colors-by-class-name[absolute])
    ]

    >> 'without colors' {
      var output = (
        capture {
          use-diagram:use-diagram &format=graphviz
        }
      )

      put $output |
        should-contain-all $always-displayed-lines

      put $output |
        should-contain-none $color-lines
    }

    >> 'with colors' {
      capture {
        use-diagram:use-diagram &colors &format=graphviz
      } |
        should-contain-all [
          $@always-displayed-lines
          $@color-lines
        ]
    }
  }

  >> 'when requesting Mermaid format' {
    var always-displayed-lines = [
      '  layout: elk'

      'flowchart BT'

      'elvish/use-diagram[elvish/use-diagram] --> path{{path}}'

      'elvish/use-diagram[elvish/use-diagram] --> github.com/giancosta86/ethereal/v1/map(github.com/giancosta86/ethereal/v1/map)'

      'elvish/use-diagram[elvish/use-diagram] --> analysis/files[analysis/files]'
    ]

    var color-lines = [
      'classDef standard fill:'$shared:use-colors-by-class-name[standard]
      'path:::standard'

      'classDef absolute fill:'$shared:use-colors-by-class-name[absolute]
      'github.com/giancosta86/ethereal/v1/seq:::absolute'

      'classDef relative fill:'$shared:use-colors-by-class-name[relative]
      'analysis/files:::relative'
    ]

    >> 'without colors' {
      var output = (
        capture {
          use-diagram:use-diagram &format=mermaid
        }
      )

      put $output |
        should-contain-all $always-displayed-lines

      put $output |
        should-contain-none $color-lines
    }

    >> 'with colors' {
      capture {
        use-diagram:use-diagram &colors &format=mermaid
      } |
        should-contain-all [
          $@always-displayed-lines
          $@color-lines
        ]
    }
  }
}