# Githubから基本情報(Recovery)を取得するジョブ
# 一度に取得する上限値を引数に持つ
#
# [即時実行]
#   GithubProjectRecoveryCrawler.new.perform(100)
class GithubProjectRecoveryCrawler < GithubProjectDetailCrawler
  queue_as :github_project_detail_crawler

  def perform(max_count)
    targets = InputProject.get_revocery_target(count)
    # マルチプロセスで詳細情報を収集
    Parallel.each(targets, in_processes: Settings.detail_crawler_process_count) do |target|
      ActiveRecord::Base.connection_pool.with_connection do
        main(target)
      end
    end
  end

  def main(target)
    begin
      # 基本情報収集
      results = fetch_project_by_project_id(target.github_item_id)
      save_projects(target, results)
    rescue => e
      target.attributes = {
        crawl_status: CrawlStatus::ERROR
      }
      target.save!
      Rails.logger.error('GithubProjectRecoveryCrawler CrawlError:' + e.message)
    end
  end

  private

  # 指定したプロジェクトIDよりリポジトリ基本情報取得
  def fetch_project_by_project_id(project_id)
    Rails.logger.info("fetch project #{project_id} for recovery")

    p = proc do |page|
      client = GithubClient.new(Settings.github_crawl_token)
      res = client.get_repository_by_project_id(
        project_id
      )
      res
    end

    fetch_projects_detail_with_rate_limit(
      p
    ).flatten
  end

  # リポジトリの結果結果を保存
  def save_projects(target, results)
    results.each do |result|
      target.attributes = {
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
        language: result.language || language,
        default_branch: result.default_branch
      }
      pj.save!
    end
  end

end
