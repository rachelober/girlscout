require File.expand_path(File.join(File.dirname(__FILE__), "../lib/girlscout.rb"))
require 'fileutils'

namespace :girlscout do
  desc 'Sets up Girlscout'
  task :setup do
    FileUtils.mkdir_p(Rails.root.join("db/data/girlscout"))
    if !File.exists?(Rails.root.join("public/sitemap.xml"))
      FileUtils.cp(Rails.root.join("vendor/plugins/girlscout/samples/sitemap.xml"), Rails.root.join("public/sitemap.xml"))
      puts "A sample sitemap.xml has been placed in your /public directory. Please edit it with the urls you would like to crawl."
    end
  end

  desc 'Crawls all the urls in the current sitemap'
  task :crawl => [:setup, :cleanup] do
    scout = Girlscout.new(Rails.root.join('public/sitemap.xml'))
    responses = scout.crawl
    if responses.empty?
      puts "No URIs found in sitemap.xml"
    else
      puts "Results:"
      responses.each do |response, url_ary|
        FileUtils.touch(Rails.root.join("db/data/girlscout/#{response}.yml"))
        yml = File.new(Rails.root.join("db/data/girlscout/#{response}.yml"), "r+")
        url_ary.each do |url|
          yml.puts url
        end
        puts "#{response}: #{url_ary.count}"
      end
    end
  end

  desc 'Cleans up girlscout directory'
  task :cleanup do
    FileUtils.rm_r(Dir.glob(Rails.root.join("db/data/girlscout/*")))
  end
end