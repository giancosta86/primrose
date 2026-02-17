use re
use str
use github.com/giancosta86/ethereal/v1/lang
use ../analysis/text

var -qualified-identifier-regex = '([A-Za-z0-9\-]+):([A-Za-z0-9\-~:]+)'

#
# Emits the qualified identifiers - i.e., «A:B» - in the given Elvish source code.
#
# Every emitted identifier is a map having the following fields:
#
# * `line-number`
#
# * `namespace` - the part before the ":"
#
# * `identifier` - the part after the ":"
#
# In case of multiple namespaces, only leftmost one constitutes the `namespace` field.
#
fn find-all { |@arguments|
  var source-code = (lang:get-single-input $arguments)

  text:line-by-line $source-code { |line-number line|
    if (str:has-prefix $line '#') {
      continue
    }

    re:find $-qualified-identifier-regex $line | each { |match|
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