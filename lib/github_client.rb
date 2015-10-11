class GithubClient
  GITHUB_API_BASE_URL = 'https://api.github.com'
  SEARCH_REPOSITORY_URL = '/search/repositories'
  REPOSITORY_URL = '/repositories'
  BRANCHES_URL = '/branches'
  TAGS_URL = '/tags'

  # search_repository 1ページあたりに取得可能な最大件数
  GITHUB_SEARCH_REPOSITORY_MAX_PER = 100
  # search_repository 一度に取得可能な最大件数
  GITHUB_SEARCH_REPOSITORY_MAX_TOTAL_COUNT = 1000
  # search_repository 最大ページ数
  GITHUB_SEARCH_REPOSITORY_MAX_PAGE_COUNT = 1000 / 100

  def initialize(token)
    @token = token
  end

  # ex. search_repositories_by_created_at("2014-08-20T00:00:00Z", "2014-08-20T23:59:59Z")
  def search_repositories_by_created_at(from_date, to_date, page: 1, language: 'ruby', sort: 'stars')
    path = "#{SEARCH_REPOSITORY_URL}?q=language:#{language} "\
           "created:\"#{from_date}..#{to_date}\"&sort=#{sort}"
    Rails.logger.info("GithubClient Access to #{path} - page: #{page}")

    GithubSearchRepositoryResponse.parse(get_request_to(path, page: page), page)
  end

  def get_repositories_branches_by_project_id(project_id, page: 1)
    path = "#{REPOSITORY_URL}/#{project_id}#{BRANCHES_URL}"
    Rails.logger.info("GithubClient Access to #{path} - page: #{page}")

    GithubRepositoryResponse.parse(get_request_to(path, page: page), page)
  end

  def get_repositories_tags_by_project_id(project_id, page: 1)
    path = "#{REPOSITORY_URL}/#{project_id}#{TAGS_URL}"
    Rails.logger.info("GithubClient Access to #{path} - page: #{page}")

    GithubRepositoryResponse.parse(get_request_to(path, page: page), page)
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
