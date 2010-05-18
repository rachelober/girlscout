#!/usr/bin/env ruby
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/girlscout.rb"))
require 'test/unit'
require 'fileutils'
require 'fakeweb'

class TestGirlscout < Test::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://example.com/test1", :body => "Hello World!", :status => ["200", "OK"])
    FakeWeb.register_uri(:get, "http://example.com/test2", :body => "Hello World!", :status => ["200", "OK"])
    FakeWeb.register_uri(:get, "http://example.com/test3", :body => "Hello World!", :status => ["200", "OK"])
    FakeWeb.register_uri(:get, "http://example.com/test4", :body => "Hello World!", :status => ["301", "Moved Permanently"])
    FakeWeb.register_uri(:get, "http://example.com/test5", :body => "Hello World!", :status => ["302", "Found"])
    FakeWeb.register_uri(:get, "http://example.com/test6", :body => "Hello World!", :status => ["401", "Unauthorized"])
    FakeWeb.register_uri(:get, "http://example.com/test7", :body => "Hello World!", :status => ["403", "Forbidden"])
    FakeWeb.register_uri(:get, "http://example.com/test8", :body => "Hello World!", :status => ["404", "Not Found"])
    FakeWeb.register_uri(:get, "http://example.com/test9", :body => "Hello World!", :status => ["500", "Internal Server Error"])
    
    FakeWeb.register_uri(:get, "http://www.example2.com/test1", :body => "Hello World!", :status => ["200", "OK"])
    FakeWeb.register_uri(:get, "http://www.example2.com/test2", :body => "Hello World!", :status => ["200", "OK"])
    FakeWeb.register_uri(:get, "http://www.example2.com/test3", :body => "Hello World!", :status => ["200", "OK"])
    FakeWeb.register_uri(:get, "http://www.example2.com/test4", :body => "Hello World!", :status => ["301", "Moved Permanently"])
    FakeWeb.register_uri(:get, "http://www.example2.com/test5", :body => "Hello World!", :status => ["302", "Found"])
    FakeWeb.register_uri(:get, "http://www.example2.com/test6", :body => "Hello World!", :status => ["401", "Unauthorized"])
    FakeWeb.register_uri(:get, "http://www.example2.com/test7", :body => "Hello World!", :status => ["403", "Forbidden"])
    FakeWeb.register_uri(:get, "http://www.example2.com/test8", :body => "Hello World!", :status => ["404", "Not Found"])
    FakeWeb.register_uri(:get, "http://www.example2.com/test9", :body => "Hello World!", :status => ["500", "Internal Server Error"])
  end
  
  def teardown
    FakeWeb.clean_registry
  end
  
  def test_file_not_found
    assert_raise(ArgumentError) {Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample_not_found.xml")))}
  end
  
  def test_file_not_readable
    FileUtils.chmod(0000, File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    
    assert_raise(ArgumentError) {Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))}
    
    FileUtils.chmod(0755, File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
  end
  
  def test_parse_urls
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = [
      "http://example.com/test1",
      "http://example.com/test2",
      "http://example.com/test3",
      "http://example.com/test4",
      "http://example.com/test5",
      "http://example.com/test6",
      "http://example.com/test7",
      "http://example.com/test8",
      "http://example.com/test9",
      "http://example.com/test|"]
    
    assert_equal(expected, scout.parse_urls)
    assert_equal([], scout.urls)
  end
  
  def test_parse_urls!
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = [
      "http://example.com/test1",
      "http://example.com/test2",
      "http://example.com/test3",
      "http://example.com/test4",
      "http://example.com/test5",
      "http://example.com/test6",
      "http://example.com/test7",
      "http://example.com/test8",
      "http://example.com/test9",
      "http://example.com/test|"]
    
    assert_equal(expected, scout.parse_urls!)
    assert_equal(expected, scout.urls)
  end
  
  def test_crawl
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {
      "error"=>[
        "http://example.com/test|"],
      "200"=>[
        "http://example.com/test1",
        "http://example.com/test2",
        "http://example.com/test3"],
      "301"=>[
        "http://example.com/test4"],
      "302"=>[
        "http://example.com/test5"],
      "401"=>[
        "http://example.com/test6"],
      "403"=>[
        "http://example.com/test7"],
      "404"=>[
        "http://example.com/test8"],
      "500"=>[
        "http://example.com/test9"]}
    
    scout.parse_urls!
    assert_equal(expected, scout.crawl)
  end
  
  def test_crawl_with_host
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {
      "error"=>["http://example.com/test|"],
      "403"=>["http://www.example2.com/test7"],
      "404"=>["http://www.example2.com/test8"],
      "200"=>[
        "http://www.example2.com/test1",
        "http://www.example2.com/test2",
        "http://www.example2.com/test3"],
      "301"=>["http://www.example2.com/test4"],
      "500"=>["http://www.example2.com/test9"],
      "401"=>["http://www.example2.com/test6"],
      "302"=>["http://www.example2.com/test5"]}
    
    scout.parse_urls!
    assert_equal(expected, scout.crawl("www.example2.com"))
  end
  
  def test_responses
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {
      "error"=>[
        "http://example.com/test|"],
      "200"=>[
        "http://example.com/test1",
        "http://example.com/test2",
        "http://example.com/test3"],
      "301"=>[
        "http://example.com/test4"],
      "302"=>[
        "http://example.com/test5"],
      "401"=>[
        "http://example.com/test6"],
      "403"=>[
        "http://example.com/test7"],
      "404"=>[
        "http://example.com/test8"],
      "500"=>[
        "http://example.com/test9"]}
    expected_200 = ["http://example.com/test1", "http://example.com/test2", "http://example.com/test3"]
    expected_301 = ["http://example.com/test4"]
    expected_302 = ["http://example.com/test5"]
    expected_401 = ["http://example.com/test6"]
    expected_403 = ["http://example.com/test7"]
    expected_404 = ["http://example.com/test8"]
    expected_500 = ["http://example.com/test9"]
    expected_error = ["http://example.com/test|"]
    
    scout.parse_urls!
    assert(scout.crawl!)
    assert_equal(expected, scout.responses)
    assert_equal(expected_200, scout.responses("200"))
    assert_equal(expected_301, scout.responses("301"))
    assert_equal(expected_302, scout.responses("302"))
    assert_equal(expected_401, scout.responses("401"))
    assert_equal(expected_403, scout.responses("403"))
    assert_equal(expected_404, scout.responses("404"))
    assert_equal(expected_500, scout.responses("500"))
    assert_equal(expected_error, scout.responses("error"))
    assert_equal(nil, scout.responses("undefined"))
  end
  
  def test_responses_no_crawl
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    
    assert_raise(StandardError) {scout.responses}    
  end
  
  def test_crawl_with_start
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {
      "error"=>[
        "http://example.com/test|"],
      "200"=>[
        "http://example.com/test3"],
      "301"=>[
        "http://example.com/test4"],
      "302"=>[
        "http://example.com/test5"],
      "401"=>[
        "http://example.com/test6"],
      "403"=>[
        "http://example.com/test7"],
      "404"=>[
        "http://example.com/test8"],
      "500"=>[
        "http://example.com/test9"]}
    scout.parse_urls!
    assert_equal(expected, scout.crawl(nil, nil, 2))
  end
  
  def test_crawl_with_limit
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {
      "200"=>[
        "http://example.com/test1",
        "http://example.com/test2"]}
    
    scout.parse_urls!
    assert_equal(expected, scout.crawl(nil, nil, 0, 2))
  end
  
  def test_crawl_with_start_and_limit
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {
      "200"=>["http://example.com/test3"],
      "301"=>["http://example.com/test4"],
      "401"=>["http://example.com/test6"],
      "302"=>["http://example.com/test5"]}
    
    scout.parse_urls!
    assert_equal(expected, scout.crawl(nil, nil, 2, 4))
  end
end