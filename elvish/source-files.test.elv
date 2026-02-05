use ./source-files

>> 'Getting the Elvish source files' {
  >> 'by default' {
    var actual-files = [(source-files:get-all)]

    put $actual-files |
      should-contain source-files.elv

    put $actual-files |
      should-not-contain source-files.test.elv
  }

  >> 'when including test files' {
    var actual-files = [(source-files:get-all &include-tests)]

    put $actual-files |
      should-contain source-files.elv

    put $actual-files |
      should-contain source-files.test.elv
  }
}