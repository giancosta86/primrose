use github.com/giancosta86/ethereal/v1/seq
use ../qualified-identifiers
use ../uses

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