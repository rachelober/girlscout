#!/usr/bin/env ruby
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/girlscout.rb"))
require 'test/unit'
require 'fileutils'

class TestGirlscout < Test::Unit::TestCase
  def setup
  end
  
  def teardown
  end
  
  def test_file_not_found
    assert_raise(ArgumentError) {Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample_not_found.xml")))}
  end
  
  def test_file_not_readable
    FileUtils.chmod(0000, File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample_not_readable.xml")))
    assert_raise(ArgumentError) {Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample_not_readable.xml")))}
    FileUtils.chmod(0755, File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample_not_readable.xml")))
  end
  
  def test_parse_urls
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = ["http://www.foodandwine.com",
       "http://www.foodandwine.com/",
       "http://www.foodandwine.com/promo/?cid=button",
       "http://www.foodandwine.com/slideshows/spring-produce",
       "http://www.foodandwine.com/slideshows/spring-produce/3",
       "http://www.foodandwine.com/slideshows/gail-simmons-passover/4",
       "http://www.foodandwine.com/cookingguides/easter-passover",
       "http://www.foodandwine.com/slideshows/lamb/19",
       "http://www.foodandwine.com/slideshows/peas",
       "http://www.foodandwine.com/willbe404",
       "http://www.foodandwine.com/will|be|error"]
    assert_equal(expected, scout.parse_urls)
  end
  
  def test_crawl
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {"error"=>["http://www.foodandwine.com/will|be|error"],
     "404"=>["http://www.foodandwine.com/willbe404"],
     "200"=>
      ["http://www.foodandwine.com",
       "http://www.foodandwine.com/",
       "http://www.foodandwine.com/promo/?cid=button",
       "http://www.foodandwine.com/slideshows/spring-produce",
       "http://www.foodandwine.com/slideshows/spring-produce/3",
       "http://www.foodandwine.com/slideshows/gail-simmons-passover/4",
       "http://www.foodandwine.com/cookingguides/easter-passover",
       "http://www.foodandwine.com/slideshows/lamb/19",
       "http://www.foodandwine.com/slideshows/peas"]}
    assert_equal(expected, scout.crawl)
  end
  
  def test_crawl_with_host
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {"error"=>["http://www.foodandwine.com/will|be|error"],
     "404"=>
      ["http://www.google.com/promo/?cid=button",
       "http://www.google.com/slideshows/spring-produce",
       "http://www.google.com/slideshows/spring-produce/3",
       "http://www.google.com/slideshows/gail-simmons-passover/4",
       "http://www.google.com/cookingguides/easter-passover",
       "http://www.google.com/slideshows/lamb/19",
       "http://www.google.com/slideshows/peas",
       "http://www.google.com/willbe404"],
     "200"=>["http://www.google.com", "http://www.google.com/"]}
    assert_equal(expected, scout.crawl("www.google.com"))
  end
  
  def test_responses
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {"error"=>["http://www.foodandwine.com/will|be|error"],
     "404"=>["http://www.foodandwine.com/willbe404"],
     "200"=>
      ["http://www.foodandwine.com",
       "http://www.foodandwine.com/",
       "http://www.foodandwine.com/promo/?cid=button",
       "http://www.foodandwine.com/slideshows/spring-produce",
       "http://www.foodandwine.com/slideshows/spring-produce/3",
       "http://www.foodandwine.com/slideshows/gail-simmons-passover/4",
       "http://www.foodandwine.com/cookingguides/easter-passover",
       "http://www.foodandwine.com/slideshows/lamb/19",
       "http://www.foodandwine.com/slideshows/peas"]}
    expected_404 = ["http://www.foodandwine.com/willbe404"]
    expected_200 = ["http://www.foodandwine.com", "http://www.foodandwine.com/", "http://www.foodandwine.com/promo/?cid=button", "http://www.foodandwine.com/slideshows/spring-produce", "http://www.foodandwine.com/slideshows/spring-produce/3", "http://www.foodandwine.com/slideshows/gail-simmons-passover/4", "http://www.foodandwine.com/cookingguides/easter-passover", "http://www.foodandwine.com/slideshows/lamb/19", "http://www.foodandwine.com/slideshows/peas"]
    expected_error = ["http://www.foodandwine.com/will|be|error"]
    
    assert(scout.crawl)
    assert_equal(expected, scout.responses)
    assert_equal(expected_404, scout.responses("404"))
    assert_equal(expected_200, scout.responses("200"))
    assert_equal(expected_error, scout.responses("error"))
    assert_equal(nil, scout.responses("undefined"))
  end
  
  def test_responses_no_crawl
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    
    assert_raise(StandardError) {scout.responses}    
  end
  
  def test_crawl_with_start
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {"error"=>["http://www.foodandwine.com/will|be|error"],
     "404"=>["http://www.foodandwine.com/willbe404"],
     "200"=>
      ["http://www.foodandwine.com/promo/?cid=button",
       "http://www.foodandwine.com/slideshows/spring-produce",
       "http://www.foodandwine.com/slideshows/spring-produce/3",
       "http://www.foodandwine.com/slideshows/gail-simmons-passover/4",
       "http://www.foodandwine.com/cookingguides/easter-passover",
       "http://www.foodandwine.com/slideshows/lamb/19",
       "http://www.foodandwine.com/slideshows/peas"]}
    
    assert_equal(expected, scout.crawl(nil, nil, 2))
  end
  
  def test_crawl_with_limit
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {"200" => ["http://www.foodandwine.com", "http://www.foodandwine.com/"]}
    
    assert_equal(expected, scout.crawl(nil, nil, 0, 2))
  end
  
  def test_crawl_with_start_and_limit
    scout = Girlscout.new(File.expand_path(File.join(File.dirname(__FILE__), "/sitemaps/sample.xml")))
    expected = {"200"=> ["http://www.foodandwine.com/promo/?cid=button",
      "http://www.foodandwine.com/slideshows/spring-produce"]}
    
    assert_equal(expected, scout.crawl(nil, nil, 2, 2))
  end
end