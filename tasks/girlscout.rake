require File.expand_path(File.join(File.dirname(__FILE__), "../lib/girlscout.rb"))
require 'fileutils'

DIR = Time.now.strftime("%Y%m%d%H%M%S")

namespace :girlscout do
  desc 'Sets up Girlscout'
  task :setup do
    FileUtils.mkdir_p(Rails.root.join("db/data/girlscout/#{DIR}"))
    if !File.exists?(Rails.root.join("public/sitemap.xml"))
      FileUtils.cp(Rails.root.join("vendor/plugins/girlscout/samples/sitemap.xml"), Rails.root.join("public/sitemap.xml"))
      puts "A sample sitemap.xml has been placed in your /public directory. Please edit it with the urls you would like to crawl."
    end
  end

  desc 'Crawls all the urls in the current sitemap'
  task :crawl => [:setup] do
    file = ENV['file'] || 'public/sitemap.xml'
    host = ENV['host'] || nil
    scout = Girlscout.new(Rails.root.join(file))
    responses = scout.crawl(host)
    if responses.empty?
      puts "No URIs found in sitemap"
    else
      results = File.new(Rails.root.join("db/data/girlscout/#{DIR}/results.yml"), "w+")
      results.puts "Results for #{file}:"
      responses.each do |response, url_ary|
        yml = File.open(Rails.root.join("db/data/girlscout/#{DIR}/#{response}.yml"), "w+")
        url_ary.each do |url|
          yml.puts url
        end
        results.puts "#{response}: #{url_ary.size}"
      end
      puts "\n"
      results.rewind
      results.each {|x| puts x}
      results.close
    end
  end
end