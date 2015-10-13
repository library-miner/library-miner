class RubyGemsClient
  RUBY_GEMS_BASE_URL = 'https://rubygems.org'
  GEM_API_URL = '/api/v1/gems'

  # ex. get_ruby_gems_information_by_name('rails')
  def get_ruby_gems_information_by_name(name)
    path = "#{RUBY_GEMS_BASE_URL}#{GEM_API_URL}/"\
           "#{name}.json"
    Rails.logger.info("RubyGemsClient Access to #{path}")

    RubyGemResponse.parse(get_request_to(path))
  end

  private

  def build_api_connection
    Faraday.new(url: RUBY_GEMS_BASE_URL) do |builder|
      builder.request :url_encoded
      builder.adapter Faraday.default_adapter
    end
  end

  def get_request_to(path)
    conn = build_api_connection
    conn.get do |req|
      req.url path
    end
  end

end
