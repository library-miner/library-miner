require 'tempfile'

# [使い方]
#   GemfileParser.new.parse(rubygems_contents)
#
# [戻り値]
#   Array
#     - [0] boolean - パースに成功したか
#     - [1] array - Gem Dependenciesのリスト
#     - [2] object - エラークラス
class GemfileParser
  def parse_gemfile(rubygems_contents)
    gem_lines = rubygems_contents
      .split("\n")
      .map(&:strip)
      .select { |v| v.start_with?("gem") }
    file = Tempfile.new("TemporaryGem")

    is_success = false
    error = nil
    gems = []

    begin
      file.puts(gem_lines)
      file.rewind
      gems = Bundler::Definition.build(file.path, nil, nil).dependencies
      is_success = true
    rescue => e
      error = e
    ensure
      file.close
      file.unlink
    end
    [is_success, gems, error]
  end
end
