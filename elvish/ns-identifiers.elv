use re
use ../analysis/text

var -ns-identifier-regex = '([A-Za-z0-9\-]+):([A-Za-z0-9\-~:]+)'

fn find-all { |source-code|
  text:line-by-line $source-code { |line-number line|
    re:find $-ns-identifier-regex $line | each { |match|
      var groups = $match[groups]

      var namespace = $groups[1][text]
      var identifier = $groups[2][text]

      put [
        &line-number=$line-number
        &namespace=$namespace
        &identifier=$identifier
      ]
    }
  }
}