use re
use str
use github.com/giancosta86/ethereal/v1/seq
use ../analysis/text

var standard = 'S'
var absolute = 'A'
var relative = 'R'

var -use-regex = '(?m)^\s*use\s+(\S+)(?:\s+(\S+))?\s*(?:#.*)?$'

fn find-all { |&kinds=[$standard $absolute $relative] source-code|
  text:line-by-line $source-code { |line-number line|
    re:find $-use-regex $line | each { |match|
      var groups = $match[groups]

      var reference = $groups[1][text]
      var alias = (seq:coalesce-empty $groups[2][text])

      var reference-components = [(str:split / $reference)]

      var kind = (
        if (==s $reference[0] '.') {
          put $relative
        } elif (== 1 (count $reference-components)) {
          put $standard
        } else {
          put $absolute
        }
      )

      if (not (has-value $kinds $kind)) {
        continue
      }

      var namespace = (coalesce $alias $reference-components[-1])

      put [
        &line-number=$line-number
        &reference=$reference
        &alias=$alias
        &namespace=$namespace
        &kind=$kind
      ]
    }
  }
}
