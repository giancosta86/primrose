use ./files

fn with-temp-source-tree { |block|
  fs:with-temp-dir { |temp-dir|
    tmp pwd = $temp-dir

    print Alpha > alpha.elv
    print Beta > beta.elv
    print Gamma > gamma.elv

    var temp-files = [alpha.elv beta.elv gamma.elv]

    $block $temp-files
  }
}

fn file-length-analyzer { |_ content|
  put [
    &text-len=[$content (count $content)]
  ]
}

fn more-sophisticated-analyzer { |path content|
  put [
    &text-len=[$content (count $content)]
    &name-without-extension=$path[..-4]
  ]
}

fn beta-excluding-analyzer { |path content|
  if (not-eq Beta $content) {
    file-length-analyzer $path $content
  } else {
    put $nil
  }
}

>> 'Analysis' {
  >> 'by files' {
    >> 'should provide a merged map of results, whose key is the file path' {
      with-temp-source-tree { |temp-files|
        all $temp-files |
          files:analyze $file-length-analyzer~ |
          should-be [
            &alpha.elv=[
              &text-len=[Alpha (num 5)]
            ]
            &beta.elv=[
              &text-len=[Beta (num 4)]
            ]
            &gamma.elv=[
              &text-len=[Gamma (num 5)]
            ]
          ]
        }
    }
  }

    >> 'should be able to set a sub-map as the result for each file' {
      with-temp-source-tree { |temp-files|
        all $temp-files |
          files:analyze $more-sophisticated-analyzer~ |
          should-be [
            &alpha.elv=[
              &name-without-extension=alpha
              &text-len=[Alpha (num 5)]
            ]
            &beta.elv=[
              &name-without-extension=beta
              &text-len=[Beta (num 4)]
            ]
            &gamma.elv=[
              &name-without-extension=gamma
              &text-len=[Gamma (num 5)]
            ]
          ]
      }
    }

  >> 'should not report a path having $nil as its analysis result' {
    with-temp-source-tree { |temp-files|
      all $temp-files |
        files:analyze $beta-excluding-analyzer~ |
        should-be [
          &alpha.elv=[
            &text-len=[Alpha (num 5)]
          ]
          &gamma.elv=[
            &text-len=[Gamma (num 5)]
          ]
        ]
    }
  }
}