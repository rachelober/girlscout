require File.expand_path(File.join(File.dirname(__FILE__), "../lib/girlscout.rb"))
require 'fileutils'

namespace :girlscout do
  desc 'Sets up Girlscout'
  task :setup do
    if !File.exists?(Rails.root.join("public/sitemap.xml"))
      FileUtils.cp(Rails.root.join("vendor/plugins/girlscout/samples/sitemap.xml"), Rails.root.join("public/sitemap.xml"))
      puts "A sample sitemap.xml has been placed in your /public directory. Please edit it with the urls you would like to crawl."
    end
  end

  desc 'Crawls all the urls in the current sitemap'
  task :crawl => [:setup] do
    file = ENV['file'] || 'public/sitemap.xml'
    host = ENV['host']
    port = ENV['port']
    chunk = ENV['chunk'] ? ENV['chunk'].to_i : 50000
    wait = ENV['wait'] ? ENV['wait'].to_i : 3
    dir = ENV['dir']
    scout = Girlscout.new(Rails.root.join(file))
    scout.parse_urls!
    start = 0
    
    while start < scout.urls.size
      limit = chunk
      scout.crawl!(host, port, start, limit, wait)
      scout.print_responses(dir)
      start = start + limit
    end
  end
end