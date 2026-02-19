use str
use ./text

>> 'Analysis' {
  >> 'of a string, line by line' {
    >> 'should call the consumer, line by line' {
      var text = (
        all [
          'First line'
          'Second line'
          'Third line'
        ] |
          str:join "\n"
      )

      text:line-by-line $text { |line-number line|
        put '--- '$line-number': '$line' ---'
      } |
        should-emit [
          '--- 1: First line ---'
          '--- 2: Second line ---'
          '--- 3: Third line ---'
        ]
    }
  }
}