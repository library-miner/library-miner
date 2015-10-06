class GithubClient
  GITHUB_API_BASE_URL = 'https://api.github.com'
  SEARCH_REPOSITORY_URL = '/search/repositories'

  GITHUB_SEARCH_REPOSITORY_MAX_PER = 100

  def initialize(token)
    @token = token
  end

  # ex. search_repositories_by_created_at("2014-08-20T00:00:00Z", "2014-08-20T23:59:59Z")
  def search_repositories_by_created_at(from_date, to_date, page: 1, language: 'ruby', sort: 'stars')
    path = "#{SEARCH_REPOSITORY_URL}?q=language:#{language} "\
           "created:\"#{from_date}..#{to_date}\"&sort=#{sort}"
    Rails.logger.info("GithubClient Access to #{path}")

    GithubSearchRepositoryResponse.parse(get_request_to(path, page: page))
  end

  private

  def build_api_connection
    Faraday.new(url: GITHUB_API_BASE_URL) do |builder|
      builder.request :url_encoded
      builder.adapter Faraday.default_adapter
    end
  end

  def get_request_to(path, page: 1)
    conn = build_api_connection
    conn.get do |req|
      req.url path, page: page, per_page: GITHUB_SEARCH_REPOSITORY_MAX_PER
      req.headers['Authorization'] = "token #{Settings.github_crawl_token}"
    end
  end
end
