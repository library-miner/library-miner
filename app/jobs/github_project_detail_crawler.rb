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
      # ツリー情報
      tree_results = fetch_projects_detail_trees_by_project_id(target.github_item_id)
      save_project_detail_trees(target.id, tree_results)

      # タグ情報
      tag_results = fetch_projects_detail_tags_by_project_id(target.github_item_id)
      save_project_detail_tags(target.id, tag_results)

      target.attributes = {
        crawl_status: CrawlStatus::DONE
      }
      target.save!
    end
  end

  # private
  # ツリー情報格納
  def save_project_detail_trees(target_id, results)
    InputBranch.where(input_project_id: target_id).delete_all
    results[0].each do |result|
      pj = InputBranch.new(
        name: result.name,
        sha: result.commit.sha,
        url: result.commit.url,
        input_project_id: target_id
      )
      pj.save!
    end
  end

  # タグ情報格納
  def save_project_detail_tags(target_id, results)
    InputTag.where(input_project_id: target_id).delete_all
    results[0].each do |result|
      # binding.pry
      pj = InputTag.new(
        name: result.name,
        sha: result.commit.sha,
        url: result.commit.url,
        input_project_id: target_id
      )
      pj.save!
    end
  end

  # 指定したプロジェクトIDよりリポジトリ詳細情報(ツリー)取得
  def fetch_projects_detail_trees_by_project_id(project_id)
    Rails.logger.info("fetch project detail trees #{project_id}")

    p = proc do |page|
      client = GithubClient.new(Settings.github_crawl_token)
      res = client.get_repositories_trees_by_project_id(
        project_id,
        page: page
      )
      Rails.logger.info("fetch project #{project_id} (page: #{page})")
      res
    end

    results = fetch_projects_detail_with_rate_limit(
      p
    )
  end

  # 指定したプロジェクトIDよりリポジトリ詳細情報(タグ)取得
  def fetch_projects_detail_tags_by_project_id(project_id)
    Rails.logger.info("fetch project detail tags #{project_id}")

    p = proc do |page|
      client = GithubClient.new(Settings.github_crawl_token)
      res = client.get_repositories_tags_by_project_id(
        project_id,
        page: page
      )
      Rails.logger.info("fetch project #{project_id} (page: #{page})")
      res
    end

    results = fetch_projects_detail_with_rate_limit(
      p
    )
  end

  # API制限,リトライを考慮してデータ取得　
  def fetch_projects_detail_with_rate_limit(get_repositories_proc)
    results = []
    is_success = true
    retry_count = 0
    page = 1
    has_next_page = false

    begin
      res = get_repositories_proc.call(page)

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
          fail 'Retry Limit.'
        else
          retry_count += 1
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

    results
  end
end
