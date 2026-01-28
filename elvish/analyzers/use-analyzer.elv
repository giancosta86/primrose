use ../qualified-identifiers
use ../uses

fn create { |&kinds=[$uses:standard $uses:absolute $uses:relative]|
  put { |_ source-code|
    uses:find-all &kinds=$kinds $source-code
  }
}