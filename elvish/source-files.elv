use str

#
# Emits all the `.elv` source files in the current directory, recursively navigating subdirectories.
#
# If the `include-tests` flag is enabled, `.test.elv` file paths are emitted as well.
#
fn get-all { |&include-tests=$false|
  put **.elv |
    keep-if { |file-path|
      if $include-tests {
        put $true
      } else {
        not (str:has-suffix $file-path '.test.elv')
      }
    }
}