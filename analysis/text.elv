use github.com/giancosta86/ethereal/v1/seq

fn line-by-line { |content line-number-text-consumer|
  echo $content |
    from-lines |
    seq:enumerate &start-index=1 |
    seq:spread $line-number-text-consumer
}