PgSearch.multisearch_options = {
  using: {
    tsearch: { dictionary: 'english', prefix: true },
    trigram: { threshold: 0.1 }
  }
}
