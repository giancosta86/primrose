

fn analyze { |content line-number-text-consumer|
  echo $content |
    from-lines |
    seq:enumerate &start-index=1 |
    seq:spread $line-number-text-consumer
}