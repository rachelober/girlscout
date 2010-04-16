#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'

class Girlscout
  attr_reader :file
  
  def initialize(file)
    raise ArgumentError.new("Can't find #{file}.") if !File.exists?(file)
    raise ArgumentError.new("File #{file} is not readable.") if !File.readable?(file)
    @file = file
    @responses = Hash.new
  end
  
  def crawl(subdomain = nil)
    @responses = Hash.new
    paths = Array.new
    @file = File.open(@file)
    doc = Nokogiri::XML(@file)
    doc.remove_namespaces!
    puts "\nLooking through your sitemap (this could take a while)\n"
    doc.xpath("//urlset/url/loc").each do |uri|
      uri = uri.content
      begin
        response = Net::HTTP.get_response(URI.parse(uri))
        @responses[response.code] = [] if !@responses.has_key?(response.code)
        @responses[response.code] << uri
        print "."
      rescue Timeout::Error => e
        @responses["timeout"] = [] if !@responses.has_key?("timeout")
        @responses["timeout"] << uri
        print "T"
      rescue URI::InvalidURIError
        @responses["error"] = [] if !@responses.has_key?("error")
        @responses["error"] << uri
        print "E"
      end
    end
    puts "\n"
    return @responses
  end
  
  def responses(response_code = nil)
    raise StandardError.new("Please run a crawl first.") if @responses.empty?
    if response_code
      return @responses.has_key?(response_code) ? @responses[response_code] : nil
    else
      return @responses
    end
  end
end