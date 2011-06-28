#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'fileutils'

class Girlscout
  attr_reader :file, :urls
  
  def initialize(file)
    raise ArgumentError.new("Can't find #{file}.") if !File.exists?(file)
    raise ArgumentError.new("File #{file} is not readable.") if !File.readable?(file)
    @file = file
    @responses = Hash.new
    @urls = Array.new
  end
  
  def parse_urls
    urls = Array.new
    file = File.open(@file)
    doc = Nokogiri::XML(file)
    doc.remove_namespaces!
    puts "\nLooking through your sitemap (this could take a few minutes)\n"
    doc.xpath("//urlset/url/loc").each do |uri|
      urls << uri.content
    end
    file.close
    return urls
  end
  
  def parse_urls!
    return @urls = parse_urls
  end
  
  def crawl(host = nil, port = nil, start = 0, limit = 50000, wait = nil)
    raise StandardError.new("Please run a parse_urls! first.") if @urls.empty?
    responses = Hash.new
    urls = @urls[start..(start+limit-1)]
    puts "\nTesting responses to host\n"
    urls.each do |uri|
      begin
        uri = URI.parse(uri)
        uri.host = host if host
        uri.port = port if port
        response = Net::HTTP.get_response(uri).code
        sleep(wait) if wait
        uri = uri.to_s
        print "."
      rescue Timeout::Error => e
        response = "timeout"
        print "T"
      rescue URI::InvalidURIError
        response = "error"
        print "E"
      end
      responses[response] = [] if !responses.has_key?(response)
      responses[response] << uri
    end
    STDOUT.flush
    puts "\n"
    return responses
  end
  
  def crawl!(host = nil, port = nil, start = 0, limit = 50000, wait = nil)
    return @responses = crawl(host, port, start, limit, wait)
  end
  
  def responses(response_code = nil)
    raise StandardError.new("Please run a crawl first.") if @responses.empty?
    if response_code
      return @responses.has_key?(response_code) ? @responses[response_code] : nil
    else
      return @responses
    end
  end
  
  def print_responses(dir = nil)
    Girlscout.print_responses(@responses, dir)
  end
  
  class << self
    def print_responses(responses, dir = nil)
      dir = dir || Time.now.strftime("%Y%m%d%H%M%S")
      if responses.empty?
        puts "No URIs found in sitemap"
      else
        FileUtils.mkdir_p(Rails.root.join("db/data/girlscout/#{dir}"))
        FileUtils.touch(Rails.root.join("db/data/girlscout/#{dir}/results.yml"))
        results = File.open( Rails.root.join("db/data/girlscout/#{dir}/results.yml") ) { |yf| YAML::load(yf) } || Hash.new()
        responses.each do |response, urls|
          results[response] = results.has_key?(response) ? results[response] + urls.size : urls.size
          yml = File.open(Rails.root.join("db/data/girlscout/#{dir}/#{response}.yml"), "a+")
          urls.each do |url|
            yml.puts url
          end
          yml.close
        end
        File.open( Rails.root.join("db/data/girlscout/#{dir}/results.yml"), 'w' ) do |out|
          YAML.dump( results, out )
        end
      end
    end
  end
end