# Githubから基本情報を取得するジョブ
#
# [即時実行]
# 作成日ベースで取得
#   GithubProjectCrawler.new.perform('20150101','20150102')
#   GithubProjectCrawler.perform_later('20150101','20150102')
# 更新日ベースで取得
#   GithubProjectCrawler.new.perform(
#     '20150101000000',
#     '20150101010000',
#     mode: 'UPDATED'
#   )
#   GithubProjectCrawler.perform_later(
#     '20150101000000',
#     '20150101010000',
#     mode: 'UPDATED'
#   )
class GithubProjectCrawler < Base
  queue_as :github_project_crawler

  def perform(date_from, date_to, mode: 'CREATED')
    if mode == 'CREATED'
      mode = CrawlMode::CREATED
    else
      mode = CrawlMode::UPDATED
    end
    date_from = DateTime.parse(date_from)
    date_to = DateTime.parse(date_to)

    language = 'ruby'

    if mode == CrawlMode::CREATED
      (date_from..date_to).each do |target_date|
        results = fetch_projects_created_at(target_date, language)
        save_projects(results, language)
      end
    else
      results = fetch_projects_updated_at(date_from,date_to,language)
      save_projects(results,language)
    end
  end

  private

  # リポジトリの結果結果を保存
  def save_projects(results, language)
    results.each do |result|
      pj = InputProject.find_or_initialize_by(github_item_id: result.id)
      pj.attributes = {
        crawl_status: CrawlStatus::WAITING,
        name: result.name,
        full_name: result.full_name,
        owner_id: result.owner.id,
        owner_login_name: result.owner.login,
        owner_type: result.owner.type,
        github_url: result.html_url,
        is_fork: result.fork,
        github_description: result.description,
        github_created_at: result.created_at,
        github_updated_at: result.updated_at,
        github_pushed_at: result.pushed_at,
        homepage: result.homepage,
        size: result.size,
        stargazers_count: result.stargazers_count,
        watchers_count: result.watchers_count,
        fork_count: result.forks_count,
        open_issue_count: result.open_issues_count,
        github_score: result.score,
        language: result.language || language
      }
      pj.save!
    end
  end

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
    Rails.logger.info("fetch from #{time_from} - #{time_to}")
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

  # 指定した日時に更新されたリポジトリ取得
  def fetch_projects_updated_at(from_time, to_time, language)
    Rails.logger.info("fetch target time #{from_time} - #{to_time}")
    fetch_projects_updated_between(
      from_time, to_time, language
    )
  end

  # 指定した範囲のデータ取得
  # ただし取得した結果データ件数が1000件以上だった場合は、
  # 時刻をさらに分割して検索をかける
  def fetch_projects_updated_between(time_from, time_to, language)
    Rails.logger.info("fetch from #{time_from} - #{time_to}")
    is_success, results = fetch_projects_with_rate_limit(time_from, time_to, language, mode: CrawlMode::UPDATED)
    if is_success
      results
    else
      s0 = time_from
      e1 = time_to

      e0 = s0 + ((e1 - s0) / 2)
      s1 = e0 + 1

      [
        fetch_projects_created_between(s0, e0, language, mode: CrawlMode::UPDATED),
        fetch_projects_created_between(s1, e1, language, mode: CrawlMode::UPDATED)
      ].flatten.compact
    end
  end


  # API制限を考慮してデータ取得　
  def fetch_projects_with_rate_limit(time_from, time_to, language, mode: CrawlMode::CREATED)
    results = []
    is_success = true
    client = GithubClient.new(Settings.github_crawl_token)
    retry_count = 0
    total_count = nil

    (1..GithubClient::GITHUB_SEARCH_REPOSITORY_MAX_PAGE_COUNT).each do |page|
      next unless is_success

      next if total_count.present? &&
              total_count <= ((page - 1) * GithubClient::GITHUB_SEARCH_REPOSITORY_MAX_PER)

      if mode == CrawlMode::CREATED
        res = client.search_repositories_by_created_at(
          time_from.strftime('%Y-%m-%dT%H:%M:%SZ'),
          time_to.strftime('%Y-%m-%dT%H:%M:%SZ'),
          language: language,
          page: page
        )
      else
        res = client.search_repositories_by_updated_at(
          time_from.strftime('%Y-%m-%dT%H:%M:%SZ'),
          time_to.strftime('%Y-%m-%dT%H:%M:%SZ'),
          language: language,
          page: page
        )
      end
      total_count ||= res.total_count
      Rails.logger.info("fetch #{time_from}-#{time_to}(page: #{page}, total: #{total_count})" \
                        " and results #{res.items.size}")
      if res.total_count > GithubClient::GITHUB_SEARCH_REPOSITORY_MAX_TOTAL_COUNT
        is_success = false
        next
      end
      if res.rate_limit_remaining <= 1
        # rate limit解除時間まで待つ 3秒ほど余裕を持たせる
        till_time = Time.at(res.rate_limit_reset.to_i)
        Rails.logger.warn("Rate limit exceeded. Waiting until #{till_time}")
        sleep_time = (till_time - Time.now).ceil + 3
        sleep_time = 3 if sleep_time <= 0
        sleep sleep_time
      end

      if res.items.size == 0
        Rails.logger.info("fetch failed. Retry(retry count: #{retry_count})")
        if retry_count >= 5
          fail 'Retry Limit.'
        else
          retry_count += 1
          redo
        end
      else
        retry_count = 0
        results << res.items
      end
    end

    [true, results.flatten]
  end
end
