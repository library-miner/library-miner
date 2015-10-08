class GithubSearchRepositoryResponse
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor *%i(
    is_success is_incomplete_results items total_count
    rate_limit rate_limit_remaining rate_limit_reset
    current_page has_next_page
  )

  def self.parse(response, current_page, max_page_per: 100)
    new.tap do |r|
      body = JSON.parse(response.body)
      header = response.headers

      r.is_success = response.success?
      r.is_incomplete_results = body['incomplete_results']
      r.items = if body['items'].present?
                  body['items'].map { |v| HashObject.new(v) }
                else
                  []
                end
      r.total_count = body['total_count'].to_i
      r.rate_limit = header['x-ratelimit-limit'].to_i
      r.rate_limit_remaining = header['x-ratelimit-remaining'].to_i
      r.rate_limit_reset = header['x-ratelimit-reset']

      r.current_page = current_page
      r.has_next_page = (current_page * max_page_per) < r.total_count
    end
  end
end
