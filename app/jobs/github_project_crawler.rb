# Githubから基本情報を取得するジョブ
#
# [即時実行]
#   GithubProjectClawler.new.perform(Date.new(2015,10,1), Date.new(2015,10,6))
class GithubProjectCrawler < Base
  queue_as :github_project_crawler

  def perform(date_from, date_to)
    (date_from .. date_to).each do |target_date|
      # TODO: データ保存
      fetch_projects_created_at(target_date, "ruby")
    end
  end

  private

  # 指定した日付に作成されたリポジトリ取得
  def fetch_projects_created_at(target_date, language)
    Rails.logger.info("fetch target_date #{target_date}")
    fetch_projects_created_between(
      target_date.beginning_of_day, target_date.end_of_day, language
    )
  end

  # 指定した範囲のデータ取得
  # ただし取得した結果データ件数が1000件以上だった場合は、
  # 時刻をさらに分割して検索をかける
  def fetch_projects_created_between(time_from, time_to, language)
    Rails.logger.info("FETCH FROM #{time_from} - #{time_to}")
    is_success, results = fetch_projects_with_rate_limit(time_from, time_to, language)
    if is_success
      results
    else
      s0 = time_from
      e1 = time_to

      e0 = s0 + ((e1 - s0) / 2)
      s1 = e0 + 1

      [
        fetch_projects_created_between(s0, e0, language),
        fetch_projects_created_between(s1, e1, language)
      ].flatten.compact
    end
  end

  # API制限を考慮してデータ取得　
  def fetch_projects_with_rate_limit(time_from, time_to, language)
    results = []
    is_success = true
    client = GithubClient.new(Settings.github_crawl_token)

    # FIXME: 10ページ目まであるとは限らないので以下修正
    (1..GithubClient::GITHUB_SEARCH_REPOSITORY_MAX_PAGE_COUNT).each do |page|
      next unless is_success

      res = client.search_repositories_by_created_at(
        time_from.strftime("%Y-%m-%dT%H:%M:%SZ"),
        time_to.strftime("%Y-%m-%dT%H:%M:%SZ"),
        language: language,
        page: page
      )
      if res.total_count > GithubClient::GITHUB_SEARCH_REPOSITORY_MAX_TOTAL_COUNT
        is_success = false
        next
      end
      if res.rate_limit_remaining <= 1
        # rate limit解除時間まで待つ 3秒ほど余裕を持たせる
        till_time = Time.at(res.rate_limit_reset.to_i)
        Rails.logger.info("Rate limit exceeded. Waiting until #{till_time}")
        sleep_time = (till_time - Time.now).ceil + 3
        sleep_time = 3 if sleep_time <= 0
        sleep sleep_time
      end
      results << res.items
    end

    [true, results.flatten]
  end
end
