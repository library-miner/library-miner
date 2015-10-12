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
      # ブランチ情報
      tree_results = fetch_projects_detail_branches_by_project_id(target.github_item_id)
      save_project_detail_branches(target.id, tree_results)

      # タグ情報
      tag_results = fetch_projects_detail_tags_by_project_id(target.github_item_id)
      save_project_detail_tags(target.id, tag_results)

      # ツリー情報から解析対象のファイル取得
      tree_results = fetch_projects_detail_trees_by_project_id_and_sha(
        target.github_item_id,
        InputBranch.where(
          input_project_id: target.id,
          name: 'master'
        ).first
        .try(:sha)
      )
      save_project_detail_trees_only_analyze_file(target.id, tree_results)

      # 週間コミット情報
      weekly_commit_results = fetch_projects_detail_weekly_commit_counts_by_project_id(target.github_item_id)
      save_project_detail_weekly_commit_counts(target.id, weekly_commit_results)

      # コンテンツ
      is_success = fetch_and_save_project_detail_contents(target.id)

      target.attributes = {
        crawl_status: CrawlStatus::DONE
      }
      target.save!
    end
  end

  # private
  # ブランチ情報格納
  def save_project_detail_branches(target_id, results)
    InputBranch.where(input_project_id: target_id).delete_all
    results.each do |result|
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
    results.each do |result|
      pj = InputTag.new(
        name: result.name,
        sha: result.commit.sha,
        url: result.commit.url,
        input_project_id: target_id
      )
      pj.save!
    end
  end

  # ツリー情報格納
  def save_project_detail_trees_only_analyze_file(target_id, results)
    InputTree.where(input_project_id: target_id).delete_all
    results.each do |result|
      is_target = InputTree.is_analize_target?(result.path)
      Rails.logger.info("input_project_id=#{target_id};"\
                        "path=#{result.path};"\
                        "analyze_target=#{is_target}")

      if is_target
        pj = InputTree.new(
          path: result.path,
          file_type: result.type,
          sha: result.sha,
          url: result.url,
          input_project_id: target_id
        )
        pj.save!
      end
    end
  end

  # 週間コミット数格納
  def save_project_detail_weekly_commit_counts(target_id, results)
    results.each do |result|
      pj = InputWeeklyCommitCount.find_or_initialize_by(
        input_project_id: target_id,
        index: result[:index]
      )
      pj.attributes = {
        index: result[:index],
        all_count: result[:all],
        owner_count: result[:owner],
        input_project_id: target_id
      }
      pj.save!
    end
  end

  # コンテンツ情報格納
  def save_project_detail_contents(target_id, path, sha, content)
    InputContent.where(input_project_id: target_id).delete_all
    pj = InputContent.new(
      path: path,
      sha: sha,
      content: content,
      input_project_id: target_id
    )
    pj.save!
  end

  # 指定したプロジェクトIDよりリポジトリ詳細情報(ブランチ)取得
  def fetch_projects_detail_branches_by_project_id(project_id)
    Rails.logger.info("fetch project detail branches #{project_id}")

    p = proc do |page|
      client = GithubClient.new(Settings.github_crawl_token)
      res = client.get_repositories_branches_by_project_id(
        project_id,
        page: page
      )
      Rails.logger.info("fetch project #{project_id} (page: #{page})")
      res
    end

    results = fetch_projects_detail_with_rate_limit(
      p
    ).flatten
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
    ).flatten
  end

  # 指定したプロジェクトIDとSHAよりリポジトリ詳細情報(ツリー)取得
  def fetch_projects_detail_trees_by_project_id_and_sha(project_id, sha)
    Rails.logger.info("fetch project detail trees #{project_id} #{sha}")

    p = proc do |page|
      client = GithubClient.new(Settings.github_crawl_token)
      res = client.get_repositories_trees_by_project_id_and_sha(
        project_id,
        sha,
        page: page
      )
      Rails.logger.info("fetch project #{project_id} #{sha} (page: #{page})")
      res
    end

    results = fetch_projects_detail_with_rate_limit(
      p
    ).flatten
  end

  # 指定したプロジェクトIDとSHAよりリポジトリ詳細情報(コンテンツ)取得
  def fetch_projects_detail_contents_by_project_id_and_sha(project_id, sha)
    Rails.logger.info("fetch project detail contents #{project_id} #{sha}")

    p = proc do |page|
      client = GithubClient.new(Settings.github_crawl_token)
      res = client.get_repositories_contents_by_project_id_and_sha(
        project_id,
        sha,
        page: page
      )
      Rails.logger.info("fetch project #{project_id} #{sha} (page: #{page})")
      res
    end

    results = fetch_projects_detail_with_rate_limit(
      p
    )
  end

  # 指定したプロジェクトIDよりリポジトリ詳細情報(週間コミット数)取得
  def fetch_projects_detail_weekly_commit_counts_by_project_id(project_id)
    Rails.logger.info("fetch project detail contents #{project_id}")

    p = proc do |page|
      client = GithubClient.new(Settings.github_crawl_token)
      res = client.get_repositories_weekly_commit_counts_by_project_id(
        project_id,
        page: page
      )
      Rails.logger.info("fetch project #{project_id} (page: #{page})")
      res
    end

    results = fetch_projects_detail_with_rate_limit(
      p
    ).flatten
  end

  # 指定したプロジェクトの主キーを元に解析対象のリポジトリ詳細情報(コンテンツ)取得と格納
  def fetch_and_save_project_detail_contents(input_project_id)
    is_success = true
    project_information = InputProject.find(input_project_id)
    targets = InputTree.where(input_project_id: input_project_id)

    targets.each do |target|
      is_target = InputTree.is_analize_target?(target.path)
      Rails.logger.info("input_project_id=#{input_project_id};"\
                        "path=#{target.path};"\
                        "analyze_target=#{is_target}")
      if is_target
        if InputTree.is_gemfile?(target.path)
          content = fetch_projects_detail_contents_by_project_id_and_sha(
            project_information.github_item_id,
            target.sha
          ).join
          save_project_detail_contents(
            input_project_id,
            target.path,
            target.sha,
            content
          )
        end
      end
    end

    is_success
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
