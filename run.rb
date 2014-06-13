require_relative 'multi_stalker.rb'

search_terms = [
  {
    keywords: 'wordpress hosting',
    exclude_domains: %w[wordpress.com wordpress.org]
  },
  {
    keywords: 'wordpress themes',
    exclude_domains: %w[themeforest.com woothemes.com]
  }
]

num_pages_to_stalk = 5
multi_stalkers = MultiStalker.new(search_terms, num_pages_to_stalk)
multi_stalkers.run
