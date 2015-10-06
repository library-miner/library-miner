class GithubSearchRepositoryResponse
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor *%i(
    is_success is_incomplete_results items total_count
    rate_limit rate_limit_remaining rate_limit_reset
  )

  def self.parse(response)
    self.new.tap do |r|
      body = JSON.parse(response.body)
      header = response.headers

      r.is_success = response.success?
      r.is_incomplete_results = body["incomplete_results"]
      r.items = body["items"]
      r.total_count = body["total_count"].to_i
      r.rate_limit = header["x-ratelimit-limit"].to_i
      r.rate_limit_remaining = header["x-ratelimit-remaining"].to_i
      r.rate_limit_reset = header["x-ratelimit-reset"]
    end
  end
end
