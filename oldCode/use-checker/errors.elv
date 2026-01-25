use os
use path
use ../../hash-set
use ../../map
use ../../seq
use ../syntax/analysis
use ../syntax/qualified-identifiers
use ../syntax/uses

fn -find-superfluous-uses { |uses use-namespaces accessed-namespaces|
  var unused-namespaces = (hash-set:difference $use-namespaces $accessed-namespaces)

  all $uses |
    keep-if { |use-info| hash-set:contains $unused-namespaces $use-info[namespace] } |
    each { |use-info| put [
      &line-number=$use-info[line-number]
      &reference=$use-info[reference]
    ] }
}

fn -find-dangling-namespaces { |qualified-identifiers use-namespaces accessed-namespaces|
  var dangling-namespaces = (hash-set:difference $accessed-namespaces $use-namespaces)

  all $qualified-identifiers |
    keep-if { |qualified-identifier|
      hash-set:contains $dangling-namespaces $qualified-identifier[namespace]
    }
}

fn -find-inexistent-relative-uses { |path uses|
  all $uses |
    keep-if { |use-info| ==s $use-info[kind] $uses:relative } |
    keep-if { |use-info|
      not (os:is-regular (path:join (path:dir $path) $use-info[reference]'.elv'))
    }
}

fn find { |
  &includes='**.elv'
  &excludes=$nil
  &superfluous-uses=$true
  &dangling-namespaces=$true
  &inexistent-relative-uses=$true
|
  analysis:analyze-tree &includes=$includes &excludes=$excludes [{ |path content|
    var uses = [(uses:parse $content)]

    var use-namespaces
    var qualified-identifiers
    var accessed-namespaces

    if (or $superfluous-uses $dangling-namespaces) {
      set use-namespaces = (
        all $uses |
          each { |use-info| put $use-info[namespace] } |
          hash-set:from
      )

      set qualified-identifiers = [(qualified-identifiers:parse $content)]

      set accessed-namespaces = (
        all $qualified-identifiers |
          each { |qualified-identifier| put $qualified-identifier[namespace] } |
          hash-set:from
      )
    }

    var file-result = [&]

    if $superfluous-uses {
      set file-result = (
        -find-superfluous-uses $uses $use-namespaces $accessed-namespaces |
          seq:empty-to-default [(all)] |
          map:assoc-non-nil $file-result superfluous-uses (all)
      )
    }

    if $dangling-namespaces {
      set file-result = (
        -find-dangling-namespaces $qualified-identifiers $use-namespaces $accessed-namespaces |
          seq:empty-to-default [(all)] |
          map:assoc-non-nil $file-result dangling-namespaces (all)
      )
    }

    if $inexistent-relative-uses {
      set file-result = (
        -find-inexistent-relative-uses $path $uses |
          seq:empty-to-default [(all)] |
          map:assoc-non-nil $file-result inexistent-relative-uses (all)
      )
    }

    seq:empty-to-default $file-result
  }]
}