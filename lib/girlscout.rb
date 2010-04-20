#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'

class Girlscout
  attr_reader :file
  
  def initialize(file)
    raise ArgumentError.new("Can't find #{file}.") if !File.exists?(file)
    raise ArgumentError.new("File #{file} is not readable.") if !File.readable?(file)
    @file = file
    @responses = Hash.new
  end
  
  def crawl(host = nil, port = nil)
    @responses = Hash.new
    paths = Array.new
    @file = File.open(@file)
    doc = Nokogiri::XML(@file)
    doc.remove_namespaces!
    puts "\nLooking through your sitemap (this could take a while)\n"
    doc.xpath("//urlset/url/loc").each do |uri|
      uri = uri.content
      begin
        uri = URI.parse(uri)
        uri.host = host if host
        uri.port = port if port
        response = Net::HTTP.get_response(uri).code
        uri = uri.to_s
        print "."
      rescue Timeout::Error => e
        response = "timeout"
        print "T"
      rescue URI::InvalidURIError
        response = "error"
        print "E"
      end
      @responses[response] = [] if !@responses.has_key?(response)
      @responses[response] << uri
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