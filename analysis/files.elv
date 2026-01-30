use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/parallel
use github.com/giancosta86/ethereal/v1/seq

fn -run-analyzers-on-file { |analyzers file-path file-content|
  all $analyzers | seq:reduce [&] { |cumulated-results analyzer|
    var analyzer-result = ($analyzer $file-path $file-content)

    if (not-eq $analyzer-result $nil) {
      map:merge $cumulated-results $analyzer-result
    } else {
      put $cumulated-results
    }
  }
}

fn -create-chunk-analysis-function { |analyzers|
  put { |@file-paths-in-chunk|
    all $file-paths-in-chunk | seq:reduce [&] { |results-by-file file-path|
      var file-content = (slurp < $file-path)

      var analyzer-results = (-run-analyzers-on-file $analyzers $file-path $file-content)

      if (seq:is-non-empty $analyzer-results) {
        assoc $results-by-file $file-path $analyzer-results
      } else {
        put $results-by-file
      }
    }
  }
}

#
# Receives via *pipe* the files that must be analyzed, and as *arguments* the analyzers
# that must process such files, finally returning a global map having:
#
# * for keys, the files having at least an analyzer result
#
# * as each value, a map whose keys are populated by the analyzers
#
# Analyzers are merely *functions* receving two arguments:
#
# * the file being analyzed
#
# * the text content of such files
#
# and the output can be:
#
# * a *map*, that will be merged with the maps created by the other analyzers so as to create
#   the overall map of results associated with the file
#
# * $nil, if the analyzer has nothing to associate with such file
#
# If all the analyzers return $nil for a file, such file will not be a key in the global result map.
#
# Please, note: this function is not designed to work with large files - because it keeps in memory the entire content of each file, for performance reasons.
#
# Please, note: by default, this function opens multiple files at a time and runs analyzers on them in parallel - beware of aspects such as the current working directory, external files, shared memory, and more!
#
fn analyze { |&num-workers=$parallel:DEFAULT-NUM-WORKERS @analyzers|
  var analyze-chunk-of-files~ = (-create-chunk-analysis-function $analyzers)

  parallel:fork-join &num-workers=$num-workers $analyze-chunk-of-files~ $map:merge~
}