use os
use path
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/seq
use ../qualified-identifiers
use ../uses

#
# Creates an analyzer - for `analysis/files:analyze` - returning the issues related to Elvish module uses.
#
# In particular, its flags enable the following checks:
#
# * `superfluous-uses`: the list of *use declarations* for modules that are imported but never referenced in identifiers by the current module - in the format provided by `elvish/uses:find-all`.
#
# * `dangling-identifiers`: the list of *qualified identifiers* whose namespace is not provided by an imported module; their format is the one emitted by `elvish/qualified-identifiers:find-all`.
#
# * `missing-relative-uses`: the list of *use declarations* for **relative modules** that are imported by the current module but do not exist in the file system; the format is the one of `elvish/uses:find-all`.
#
# Each active flag adds a corresponding key to the analyzer's result map - but only if the related list is not empty; the final result is such map if it has at least one key, otherwise $nil is emitted.
#
fn create { |&superfluous-uses=$true &dangling-identifiers=$true &missing-relative-uses=$true|
  put { |source-path source-code|
    if (not (or $superfluous-uses $dangling-identifiers $missing-relative-uses)) {
      put $nil
      return
    }

    var result = [&]

    var uses = [(uses:find-all $source-code)]

    if (or $superfluous-uses $dangling-identifiers) {
      var uses-by-namespace = (seq:to-map $uses (seq:make-getter namespace))

      var identifiers-by-namespace = (
        qualified-identifiers:find-all $source-code |
        each { |identifier|
          put [$identifier[namespace] $identifier]
        } |
          map:multi-value
      )

      if $superfluous-uses {
        var superfluous-uses = [(
          map:iterate $uses-by-namespace { |namespace use-declaration|
            if (not (has-key $identifiers-by-namespace $namespace)) {
              put $use-declaration
            }
          }
        )]

        set result = (seq:assoc-substantial $result superfluous-uses $superfluous-uses)
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

        set result = (seq:assoc-substantial $result dangling-identifiers $dangling-identifiers)
      }
    }

    if $missing-relative-uses {
      var missing-relative-uses = [(
        all $uses |
          keep-if { |use-declaration| eq $use-declaration[kind] $uses:relative } |
          each { |relative-use|
            var actual-referenced-path = (
              path:dir $source-path |
                path:join (all) $relative-use[reference]
            )'.elv'

            if (not (os:is-regular $actual-referenced-path)) {
              put $relative-use
            }
          }
      )]

      set result = (seq:assoc-substantial $result missing-relative-uses $missing-relative-uses)
    }

    seq:empty-to-default $result
  }
}