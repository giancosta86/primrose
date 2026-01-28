use os
use path
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/seq
use ../qualified-identifiers
use ../uses

fn create { |&superfluous-uses=$true &dangling-identifiers=$true &missing-relative-uses=$true|
  put { |source-path source-code|
    if (not (and $superfluous-uses $dangling-identifiers $missing-relative-uses)) {
      put $nil
      return
    }

    var uses = [(uses:find-all $source-code)]

    var qualified-identifiers = [(qualified-identifiers:find-all $source-code)]

    var result = [&]

    if (or $superfluous-uses $dangling-identifiers) {
      var uses-by-namespace = (
        all $uses | each { |use-declaration|
          put [$use-declaration[namespace] $use-declaration]
        } |
          make-map
      )

      var identifiers-by-namespace = (
        all $qualified-identifiers | each { |identifier|
          put [$identifier[namespace] $identifier]
        } |
          map:multi-value
      )

      if $superfluous-uses {
        var superfluous-uses = [(
          map:iterate $uses-by-namespace { |namespace declaration|
            if (not (has-key $identifiers-by-namespace $namespace)) {
              put $declaration
            }
          }
        )]

        if (seq:is-non-empty $superfluous-uses) {
          set result = (assoc $result superfluous-uses $superfluous-uses)
        }
      }

      if $dangling-identifiers {
        var dangling-identifiers = [(
          map:iterate $identifiers-by-namespace { |namespace identifiers|
            all $identifiers | each { |identifier|
              if (not (has-key $uses-by-namespace $namespace)) {
                put $identifier
              }
            }
          }
        )]

        if (seq:is-non-empty $dangling-identifiers) {
          set result = (assoc $result dangling-identifiers $dangling-identifiers)
        }
      }
    }

    if $missing-relative-uses {
      var missing-relative-uses = [(
        all $uses |
          keep-if { |use-declaration| eq $use-declaration[kind] $uses:relative } |
          each { |relative-use|
            var actual-file-path = (
              path:dir $source-path |
                path:join (all) $relative-use[reference]
            )'.elv'

            if (not (os:is-regular $actual-file-path)) {
              put $relative-use
            }
          }
      )]

      if (seq:is-non-empty $missing-relative-uses) {
        set result = (assoc $result missing-relative-uses $missing-relative-uses)
      }
    }

    seq:coalesce-empty $result
  }
}