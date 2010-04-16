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
  
  def gather_paths
    paths = Array.new
    @file = File.open(@file)
    doc = Nokogiri::XML(@file)
    doc.remove_namespaces!
    urls = doc.xpath("//urlset/url/loc").to_a
    urls.map! do |url|
      url.content.gsub(/http:\/\/www./, '')
    end
    paths = paths + urls
    @file.close
    return paths
  end
  
  def crawl
    sub_domains = [:www, :beta, :qa]
    @responses = Hash.new
    paths = gather_paths
    paths.each do |path|
      begin
        uri = "http://#{sub_domains.first}.#{path}"
        response = Net::HTTP.get_response(URI.parse(uri))
        @responses[response.code] = [] if !@responses.has_key?(response.code)
        @responses[response.code] << uri
      rescue Timeout::Error => e
        puts $!
      rescue
        puts $!
      end
    end
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