# 初回用GithubProject収集チェック

if ARGV[0].nil? || ARGV[1].nil?
  puts 'argument error'
  puts 'Usage: rails runner script/github_init_crawl_check.rb 20150101 20150103'
  exit
else
  puts InputProjectChecker.check_crawl(ARGV[0], ARGV[1])
end
