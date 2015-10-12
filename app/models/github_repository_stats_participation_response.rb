class GithubRepositoryStatsParticipationResponse
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor *%i(
    is_success items
    rate_limit rate_limit_remaining rate_limit_reset
    current_page has_next_page
  )

  def self.parse(response, current_page)
    new.tap do |r|
      body = JSON.parse(response.body)
      header = response.headers

      r.is_success = response.success?
      all_count = if body['all'].present?
                    body['all']
                  else
                    r.is_success = false
                    []
                  end
      owner_count = if body['owner'].present?
                      body['owner']
                    else
                      r.is_success = false
                      []
                    end
      r.items = []
      all_count.each_with_index do |all, i|
        r.items << { index: i, all: all, owner: owner_count[i]}
      end
      r.rate_limit = header['x-ratelimit-limit'].to_i
      r.rate_limit_remaining = header['x-ratelimit-remaining'].to_i
      r.rate_limit_reset = header['x-ratelimit-reset']

      r.current_page = current_page
      r.has_next_page = false
    end
  end
end
