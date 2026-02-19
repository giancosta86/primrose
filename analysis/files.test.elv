use ./files

fn with-temp-sources { |block|
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
    &text-and-length=[$content (count $content)]
  ]
}

fn more-sophisticated-analyzer { |_ content|
  put [
    &text=$content
    &length=(count $content)
  ]
}

fn beta-excluding-analyzer { |path content|
  if (not-eq $content Beta) {
    file-length-analyzer $path $content
  } else {
    put $nil
  }
}

>> 'Analysis' {
  >> 'by files' {
    >> 'should provide a merged map of results, whose key is the file path' {
      with-temp-sources { |temp-files|
        all $temp-files |
          files:analyze $file-length-analyzer~ |
          should-be [
            &alpha.elv=[
              &text-and-length=[Alpha (num 5)]
            ]
            &beta.elv=[
              &text-and-length=[Beta (num 4)]
            ]
            &gamma.elv=[
              &text-and-length=[Gamma (num 5)]
            ]
          ]
        }
    }

    >> 'should provide a sub-map as the result for each file' {
      with-temp-sources { |temp-files|
        all $temp-files |
          files:analyze $more-sophisticated-analyzer~ |
          should-be [
            &alpha.elv=[
              &text=Alpha
              &length=5
            ]
            &beta.elv=[
              &text=Beta
              &length=4
            ]
            &gamma.elv=[
              &text=Gamma
              &length=5
            ]
          ]
      }
    }

    >> 'should not report a path having $nil as its analysis result' {
      with-temp-sources { |temp-files|
        all $temp-files |
          files:analyze $beta-excluding-analyzer~ |
          should-be [
            &alpha.elv=[
              &text-and-length=[Alpha (num 5)]
            ]
            &gamma.elv=[
              &text-and-length=[Gamma (num 5)]
            ]
          ]
      }
    }

    >> 'should support multiple analyzers' {
      >> 'in a basic case' {
        with-temp-sources { |temp-files|
          all $temp-files |
            files:analyze $file-length-analyzer~ $more-sophisticated-analyzer~ |
            should-be [
              &alpha.elv=[
                &text-and-length=[Alpha (num 5)]
                &text=Alpha
                &length=5
              ]
              &beta.elv=[
                &text-and-length=[Beta (num 4)]
                &text=Beta
                &length=4
              ]
              &gamma.elv=[
                &text-and-length=[Gamma (num 5)]
                &text=Gamma
                &length=5
              ]
            ]
        }
      }

      >> 'when one of them returns $nil' {
        with-temp-sources { |temp-files|
          all $temp-files |
            files:analyze $beta-excluding-analyzer~ $more-sophisticated-analyzer~ |
            should-be [
              &alpha.elv=[
                &text-and-length=[Alpha (num 5)]
                &text=Alpha
                &length=5
              ]
              &beta.elv=[
                &text=Beta
                &length=4
              ]
              &gamma.elv=[
                &text-and-length=[Gamma (num 5)]
                &text=Gamma
                &length=5
              ]
            ]
        }
      }
    }

    >> 'when not passing files' {
      all [] |
        files:analyze $file-length-analyzer~ $more-sophisticated-analyzer~ |
        should-be [&]
    }

    >> 'when not passing analyzers' {
      with-temp-sources { |temp-files|
        all $temp-files |
          files:analyze |
          should-be [&]
      }
    }
  }
}