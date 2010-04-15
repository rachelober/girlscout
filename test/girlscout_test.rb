#!/usr/bin/env ruby
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/girlscout.rb"))
require 'test/unit'
require 'fileutils'

class TestGirlscout < Test::Unit::TestCase
  def setup
    @test_urls = ["foodandwine.com", "foodandwine.com/", "foodandwine.com/promo/?cid=button", "foodandwine.com/slideshows/spring-produce", "foodandwine.com/slideshows/spring-produce/3", "foodandwine.com/slideshows/gail-simmons-passover/4", "foodandwine.com/cookingguides/easter-passover", "foodandwine.com/slideshows/lamb/19", "foodandwine.com/slideshows/peas", "foodandwine.com/ururjrnrkrlri"]
  end
  
  def teardown
    
  end
  
  def test_gather_paths
    scout = Girlscout.new("/sitemaps/sample.xml")
    assert_equal(@test_urls, scout.gather_paths)
  end
  
  def test_file_not_found
    assert_raise(ArgumentError) {Girlscout.new("/sitemaps/sample_not_found.xml")}
  end
  
  def test_file_not_readable
    assert_raise(ArgumentError) {Girlscout.new("/sitemaps/sample_not_readable.xml")}
  end
  
  def test_crawl
    scout = Girlscout.new("/sitemaps/sample.xml")
    expected = {"404"=>["http://www.foodandwine.com/ururjrnrkrlri"], "200"=>["http://www.foodandwine.com", "http://www.foodandwine.com/", "http://www.foodandwine.com/promo/?cid=button", "http://www.foodandwine.com/slideshows/spring-produce", "http://www.foodandwine.com/slideshows/spring-produce/3", "http://www.foodandwine.com/slideshows/gail-simmons-passover/4", "http://www.foodandwine.com/cookingguides/easter-passover", "http://www.foodandwine.com/slideshows/lamb/19", "http://www.foodandwine.com/slideshows/peas"]}
    assert(expected, scout.crawl)
  end
  
  def test_responses
    scout = Girlscout.new("/sitemaps/sample.xml")
    expected = {"404"=>["http://www.foodandwine.com/ururjrnrkrlri"], "200"=>["http://www.foodandwine.com", "http://www.foodandwine.com/", "http://www.foodandwine.com/promo/?cid=button", "http://www.foodandwine.com/slideshows/spring-produce", "http://www.foodandwine.com/slideshows/spring-produce/3", "http://www.foodandwine.com/slideshows/gail-simmons-passover/4", "http://www.foodandwine.com/cookingguides/easter-passover", "http://www.foodandwine.com/slideshows/lamb/19", "http://www.foodandwine.com/slideshows/peas"]}
    expected_404 = ["http://www.foodandwine.com/ururjrnrkrlri"]
    expected_200 = ["http://www.foodandwine.com", "http://www.foodandwine.com/", "http://www.foodandwine.com/promo/?cid=button", "http://www.foodandwine.com/slideshows/spring-produce", "http://www.foodandwine.com/slideshows/spring-produce/3", "http://www.foodandwine.com/slideshows/gail-simmons-passover/4", "http://www.foodandwine.com/cookingguides/easter-passover", "http://www.foodandwine.com/slideshows/lamb/19", "http://www.foodandwine.com/slideshows/peas"]
    
    assert(scout.crawl)
    assert_equal(expected, scout.responses)
    assert_equal(expected_404, scout.responses("404"))
    assert_equal(expected_200, scout.responses("200"))
    assert_equal(nil, scout.responses("undefined"))
  end
  
  def test_responses_no_crawl
    scout = Girlscout.new("/sitemaps/sample.xml")
    
    assert_raise(StandardError) {scout.responses}
  end
end