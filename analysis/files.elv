use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/parallel
use github.com/giancosta86/ethereal/v1/seq

fn -create-chunk-analysis-function { |analyzers|
  put { |@file-paths-in-chunk|
    all $file-paths-in-chunk | seq:reduce [&] { |results-by-file file-path|
      var file-content = (slurp < $file-path)

      var results-by-analyzer = (
        all $analyzers | seq:reduce [&] { |cumulated-results analyzer|
          var analyzer-result = ($analyzer $file-path $file-content)

          if (not-eq $analyzer-result $nil) {
            map:merge $cumulated-results $analyzer-result
          } else {
            put $cumulated-results
          }
        }
      )

      if (seq:is-non-empty $results-by-analyzer) {
        assoc $results-by-file $file-path $results-by-analyzer
      } else {
        put $results-by-file
      }
    }
  }
}

fn analyze { |&num-workers=$parallel:DEFAULT-NUM-WORKERS @analyzers|
  var analyze-chunk-of-files~ = (-create-chunk-analysis-function $analyzers)

  parallel:fork-join &num-workers=$num-workers $analyze-chunk-of-files~ $map:merge~
}