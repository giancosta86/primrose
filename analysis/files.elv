use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/seq

fn analyze { |@analyzers|
  all |
    seq:reduce [&] { |results-by-file file-path|
      var file-content = (slurp < $file-path)

      var results-by-analyzer = (
        all $analyzers |
          seq:reduce [&] { |cumulated-result analyzer|
            var analyzer-result = ($analyzer $file-path $file-content)

            if $analyzer-result {
              map:merge $cumulated-result $analyzer-result
            } else {
              put $cumulated-result
            }
      })

      if (seq:is-non-empty $results-by-analyzer) {
        assoc $results-by-file $file-path $results-by-analyzer
      } else {
        put $results-by-file
      }
    }
}