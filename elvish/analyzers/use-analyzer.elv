use github.com/giancosta86/ethereal/v1/seq
use ../uses

#
# Creates an analyzer - for `analysis/files:analyze` - that invokes `elvish/uses:find-all` and assigns
# its emitted use declarations to the `uses` key of its result map; if no uses are found, the analyzer emits $nil instead.
#
# The `kinds` option is forwarded to the `find-all` function so as to restrict the set of emitted use declarations.
#
fn create { |&kinds=[$uses:standard $uses:absolute $uses:relative]|
  put { |_ source-code|
    var uses = [(uses:find-all &kinds=$kinds $source-code)]

    if (seq:is-non-empty $uses) {
      put [
        &uses=$uses
      ]
    } else {
      put $nil
    }
  }
}