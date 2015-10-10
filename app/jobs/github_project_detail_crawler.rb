# Githubから詳細情報を取得するジョブ
# 一度に取得する上限値を引数に持つ
#
# [即時実行]
#   GithubProjectDetailCrawler.new.perform(100)
class GithubProjectDetailCrawler < Base
  queue_as :github_project_detail_crawler

  def perform(max_count)

    targets = InputProject.get_project_detail_crawl_target(max_count)
    targets.each do |target|
      results = fetch_branches(target.full_name)
      results.each do |result|
        pj = InputBranch.find_or_initialize_by(input_project_id: target.input_project_id)
        pj.attributes = {
          name: result.name,
          sha: result.sha,
          url: result.url
        }
        pj.save!
      end
    end
  end

  #private

  # 指定したプロジェクトIDよりリポジトリ詳細情報取得
  def fetch_projects_detail_by_project_id(project_id)
    Rails.logger.info("fetch project detail #{project_id}")
    fetch_projects_detail_with_rate_limit(
      project_id
    )
  end

  # API制限,リトライを考慮してデータ取得　
  def fetch_projects_detail_with_rate_limit(project_id)
    results = []
    is_success = true
    client = GithubClient.new(Settings.github_crawl_token)
    retry_count = 0
    page = 1
    has_next_page = false

    begin
      res = client.get_repositories_by_project_id(
        project_id,
        page: page
      )

      Rails.logger.info("fetch project #{project_id} (page: #{page})")

      if res.rate_limit_remaining <= 1
        # rate limit解除時間まで待つ 3秒ほど余裕を持たせる
        till_time = Time.at(res.rate_limit_reset.to_i)
        Rails.logger.info("Rate limit exceeded. Waiting until #{till_time}")
        sleep_time = (till_time - Time.now).ceil + 3
        sleep_time = 3 if sleep_time <= 0
        sleep sleep_time
      end
      unless res.is_success
        Rails.logger.info("fetch failed. Retry(retry count: #{retry_count})")
        if retry_count >= 5
          fail "Retry Limit."
        else
          retry_count = retry_count + 1
          redo
        end
      else
        retry_count = 0
        results << res.items
        if res.has_next_page
          page_count += 1
          has_next_page = true
        else
          has_next_page = false
        end
      end
    end while has_next_page

    [true, results.flatten]
  end
end
