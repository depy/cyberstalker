require_relative 'stalker.rb'

class MultiStalker
  def initialize(search_terms, num_pages = 10)
    @search_terms = search_terms
    @num_pages = num_pages
    @stalkers = []
  end

  def run()
    release_stalkers
    join_threads
    stop_stalking
  end



  private

  def join_threads
    Thread.list.each do |t|
      t.join if t != Thread.current
    end
  end

  def release_stalkers
    for i in 0..@search_terms.length-1
      Thread.new(i) do |n|
        # Wait for captcha, delay =  6 * number of browser instances
        stalker = Stalker.new(@search_terms[n][:keywords], @num_pages, wait_timeout)
        stalker.exclude_domains(@search_terms[n][:exclude_domains])

        @stalkers << stalker
        stalker.run
      end
    end
  end

  def stop_stalking
    @stalkers.each do |stalker|
      p stalker.results
      stalker.quit
    end
  end

  def wait_timeout
    @search_terms.length * 20
  end
end