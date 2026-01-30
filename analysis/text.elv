use github.com/giancosta86/ethereal/v1/seq

#
# Splits the given content into lines, assigns a number (starting from 1) to each line,
# then calls the given consumer passing each line number and its line.
#
fn line-by-line { |content numbered-line-consumer|
  echo $content |
    from-lines |
    seq:enumerate &start-index=1 |
    seq:spread $numbered-line-consumer
}