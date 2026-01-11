use str
use ../../fs
use ../../lang
use ./analysis





describe 'Analyzing a file, line by line' {
  it 'should call the consumer, line by line' {
    var alpha-content = ^
      'First line
      Second line
      Third line'

    put [(analysis:analyze-lines $alpha-content { |line-number line|
      put ['alpha.elv' $line-number (str:trim-space $line)]
    })] |
      should-be [
        [
          alpha.elv
          1
          'First line'
        ]
        [
          alpha.elv
          2
          'Second line'
        ]
        [
          alpha.elv
          3
          'Third line'
        ]
      ]
  }
}