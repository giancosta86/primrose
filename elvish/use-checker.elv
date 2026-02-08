use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/seq
use ../analysis/files
use ./analyzers/use-issue-analyzer

fn -log-issue { |file-path issue|
  var message = (one)

  echo (styled $file-path':'$issue[line-number]': ' white bold)$message
}

fn -order-in-file {
  all |
    order &key=(seq:make-getter line-number)
}

fn -print-file-issues { |file-path issues|
  if (has-key $issues missing-relative-uses) {
    all $issues[missing-relative-uses] |
      -order-in-file |
      each { |missing-relative-use|
        put (styled 'Missing relative use: ' red bold)': '$missing-relative-use[reference] |
          -log-issue $file-path $missing-relative-use
      }
  }

  if (has-key $issues dangling-identifiers) {
    all $issues[dangling-identifiers] |
      -order-in-file |
      each { |dangling-identifier|
        put (styled 'Dangling identifier: ' yellow bold)': '$dangling-identifier[namespace]':'$dangling-identifier[identifier] |
          -log-issue $file-path $dangling-identifier
      }
  }

  if (has-key $issues superfluous-uses) {
    all $issues[superfluous-uses] |
      -order-in-file |
      each { |superfluous-use|
        put (styled 'Superfluous use: ' yellow bold)': '$superfluous-use[reference] |
          -log-issue $file-path $superfluous-use
      }
  }
}

fn -format-issues { |issues|
  if (seq:is-non-empty $issues) {
    keys $issues |
      order |
      each { |file-path|
        -print-file-issues $file-path $issues[$file-path]
      }
  } else {
    echo (styled 'No issues detected' green bold)
  }
}

#
# Analyzes all the Elvish scripts in the current directory tree, emitting issues related to use declarations.
#
# It supports the following flags:
#
# * `include-tests`: enable checks for `.test.elv` files, too. Disabled by default.
#
# * `raw`: emit a **map** in lieu of formatted output lines. Disabled by default.
#
# * `superfluous-uses`, `dangling-identifiers`, `missing-relative-uses`: the supported issue types. All enabled by default.
#
fn check-uses { |&include-tests=$false &raw=$false &superfluous-uses=$true &dangling-identifiers=$true &missing-relative-uses=$true|
  var issues = (
    fs:find-scripts &include-tests=$include-tests |
      files:analyze (
        use-issue-analyzer:create ^
          &superfluous-uses=$superfluous-uses ^
          &dangling-identifiers=$dangling-identifiers ^
          &missing-relative-uses=$missing-relative-uses
      )
  )

  if $raw {
    put $issues
  } else {
    -format-issues $issues
  }
}