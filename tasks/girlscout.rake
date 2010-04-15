require File.expand_path(File.join(File.dirname(__FILE__), "../lib/girlscout.rb"))

desc 'Sets up Girlscout'
task :setup do
end

desc 'Crawls all the urls in the current sitemap'
task :girlscout do
  sub_domains = [:www, :beta, :qa]
  responses = Hash.new
  paths = gather_paths
  paths.each do |path|
    begin
      response = Net::HTTP.get_response("#{sub_domain.first}.foodandwine.com", path)
      responses[response.code.to_sym] << "#{sub_domain.first}.foodandwine.com/#{path}"
    rescue Timeout::Error => e
      puts $!
    rescue
      puts $!
    end
  end
  puts "Results:"
  responses.each do |response, url_ary|
    yml = File.open("../db/data/sitemap_test/#{response}.yml", "r+")
    url_ary.each do |url|
      yml.puts url
    end
    puts "#{response}: #{url_ary.count}"
  end
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  test_files = FileList['test/**/*_test.rb']
  test_files.exclude('test/rails/*')
  test_files.exclude('test/haml/spec/*')
  t.test_files = test_files
  t.verbose = true
end
