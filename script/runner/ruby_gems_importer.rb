require 'CSV'

# 初回RubyGems取り込み
# name,homepage_uri,code_uri のCSVファイルを読み込む
# ex. RubyGemsClient.import_ruby_gems_information_from_csv(file_path)

if ARGV[0].nil?
  puts "argument error"
  puts "Usage: rails runner script/ruby_gems_importer.rb tmp/rubygems.csv"
  exit
else
  i = 0
  results = []
  CSV.foreach(ARGV[0]) do |name,home,code|
    i += 1
    if home == 'NULL' || home == '\N'
      home = ''
    end
    if code == 'NULL' || code == '\N'
      code = ''
    end
    if name != nil
      library = InputLibrary.new(
        name: name,
        homepage_uri: home,
        source_code_uri: code
      )
      puts i.to_s + "," + name.to_s + "," + home.to_s + "," + code.to_s
      results << library
    end
    if i % 1000 == 0
      puts "import count:" + i.to_s
      InputLibrary.import results
      results = []
    end
  end
  InputLibrary.import results
end

