require 'rubygems'
require 'selenium-webdriver'

class Stalker

  def initialize(search_string, num_pages = 10, wait_timeout = 10)
    @search_string = search_string
    @num_pages = num_pages
    @urls = []
    @wait_timeout = wait_timeout
    setup
  end

  def run
    initiate_searh
    wait_for_captcha
    @wait.until { @driver.find_element(id: 'ires' ).displayed? }

    @num_pages.times do
      results_div = @driver.find_element(:id, 'ires')
      results_lis = results_div.find_elements(class: 'g')

      extract_urls(results_lis)
      goto_next_page
      wait_for_loading
    end
  end

  def quit
    @driver.close
  end

  def results
    extract_base_urls
  end

  def exclude_domains(domains)
    domains.each do |domain|
      @search_string += " -site:#{domain}"
    end
  end



  private

  def setup
    @urls = []
    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(:timeout => @wait_timeout)
  end

  def extract_base_urls
    @urls.map do |url|
      url.slice! 'http://'
      url.slice! 'https://'
      url.split('/')[0]
    end.uniq
  end

  def initiate_searh
    # Go to google
    @driver.navigate.to 'http://google.com'

    # Put search string in input box
    element = @driver.find_element(:name, 'q')
    element.send_keys @search_string
    element.submit
  end

  def wait_for_captcha
      @wait.until { captcha_dissapeared? }
  end

  def captcha_dissapeared?
    begin
      @driver.find_element(:id, 'captcha')
    rescue Selenium::WebDriver::Error::NoSuchElementError
      true
    else
      false
    end
  end

  def extract_urls(results_lis)
    # Go trough list elements and for each element extract urls (href attribute of nested <a> element)
    results_lis.each do |li|
      url = li.find_element(tag_name: 'a').attribute('href')
      @urls << url
    end
  end

  def goto_next_page
    # Click on next page link
    next_page_link = @driver.find_element(:id, 'pnnext')
    next_page_link.click
  end

  def wait_for_loading
    begin
      # Check if loading div is present
      loading_div = @driver.find_element(class: 'flyr-o')

      # Wait for it to go away
      @wait.until { !loading_div.displayed? }
    rescue
      # Loading div is not preset. Rescue from NoSuchElementException
    end
  end
end
