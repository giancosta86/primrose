use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/seq
use ../analysis/files
use ./analyzers/use-issue-analyzer

fn -log-issue { |file-path line-number|
  var message = (one)

  echo (styled $file-path':'$line-number': ' white bold)$message
}

fn -order-in-file {
  order &key=(seq:make-getter line-number)
}

fn -try-to-print-issues { |file-path issues kind single-description color message-getter|
  if (has-key $issues $kind) {
    all $issues[$kind] |
      -order-in-file |
      each { |issue|
        var message = ($message-getter $issue)

        put (styled $single-description $color bold)': '$message |
          -log-issue $file-path $issue[line-number]
      }
  }
}

fn -print-file-issues { |file-path issues|
  -try-to-print-issues $file-path $issues missing-relative-uses 'Missing relative use' red (seq:make-getter reference)

  -try-to-print-issues $file-path $issues dangling-identifiers 'Dangling identifier' yellow { |dangling-identifier|
    put $dangling-identifier[namespace]':'$dangling-identifier[identifier]
  }

  -try-to-print-issues $file-path $issues superfluous-uses 'Superfluous use' yellow (seq:make-getter reference)
}

fn -format-issues { |issues-by-file|
  if (seq:is-non-empty $issues-by-file) {
    keys $issues-by-file |
      order |
      each { |file-path|
        -print-file-issues $file-path $issues-by-file[$file-path]
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
  var analyzer = (
    use-issue-analyzer:create ^
      &superfluous-uses=$superfluous-uses ^
      &dangling-identifiers=$dangling-identifiers ^
      &missing-relative-uses=$missing-relative-uses
  )

  var issues-by-file = (
    fs:find-scripts &include-tests=$include-tests |
      files:analyze $analyzer
  )

  if $raw {
    put $issues-by-file
  } else {
    -format-issues $issues-by-file
  }
}