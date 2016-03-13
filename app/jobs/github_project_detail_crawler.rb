# Githubから詳細情報を取得するジョブ
# 一度に取得する上限値を引数に持つ
#
# [即時実行]
#   GithubProjectDetailCrawler.new.perform(100)
class GithubProjectDetailCrawler < Base
  queue_as :github_project_detail_crawler

  # リトライ時の待ち時間
  RETRY_WAIT_TIME = 1
  # WEEKLY コミット取得の際の待ち時間
  WEEKLY_COMMIT_COUNT_WAIT_TIME = 3

  def perform(max_count)
    targets = InputProject.get_project_detail_crawl_target(
      max_count,
      Settings.client_node_id
    )
    # マルチプロセスで詳細情報を収集
    Parallel.each(targets, in_processes: Settings.detail_crawler_process_count) do |target|
      ActiveRecord::Base.connection_pool.with_connection do
        main(target)
      end
    end
  end

  def main(target)
    begin
      # ブランチ情報
      branch_results = fetch_projects_detail_branches_by_project_id(target.github_item_id)
      save_project_detail_branches(target.id, branch_results)
      master_branch_sha = InputBranch.where(
        input_project_id: target.id,
        name: 'master'
      ).first
                                     .try(:sha)

      # Masterブランチが更新されている場合に詳細情報を取得する
      if InputBranch.check_master_branch_is_update?(target.github_item_id, master_branch_sha)
        # タグ情報
        tag_results = fetch_projects_detail_tags_by_project_id(target.github_item_id)
        save_project_detail_tags(target.id, tag_results)

        # ツリー情報から解析対象のファイル取得
        tree_results = fetch_projects_detail_trees_by_project_id_and_sha(
          target.github_item_id,
          master_branch_sha
        )
        save_project_detail_trees(target.id, tree_results)

        # 週間コミット情報
        fetch_and_save_project_detail_weekly_commit_counts(
          target.id,
          target.github_item_id,
          target.github_updated_at
        )

        # 解析対象が更新されている場合コンテンツを取得
        analyze_target_update =
          InputTree.check_analyze_target_is_update?(target.github_item_id)
        if analyze_target_update
          fetch_and_save_project_detail_contents(target.id)
        end
      end

      target.attributes = {
        crawl_status: CrawlStatus::DONE
      }

    rescue => e
      target.attributes = {
        crawl_status: CrawlStatus::ERROR
      }
      Rails.logger.error('GithubProjectDetailCrawler CrawlError:' + e.message)
    end
    target.save!
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
  def save_project_detail_trees(target_id, results)
    InputTree.where(input_project_id: target_id).delete_all
    results.each do |result|
      next unless InputTree.analyze_target?(result.path)
      pj = InputTree.new(
        path: result.path,
        file_type: result.type,
        sha: result.sha,
        url: result.url,
        size: result.size,
        input_project_id: target_id
      )
      pj.save!
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
    pj = InputContent.new(
      path: path,
      sha: sha,
      content: content,
      input_project_id: target_id
    )
    pj.save!
  end

  # ライブラリ情報格納
  def save_library_information(target_id, base_information)
    pj = InputLibrary.find_or_initialize_by(
      name: base_information[:name]
    )
    pj.attributes = {
      name: base_information[:name],
      version: base_information[:version],
      homepage_uri: base_information[:homepage_uri],
      source_code_uri: base_information[:source_code_uri],
      input_project_id: target_id
    }
    pj.save!
  end

  # 依存ライブラリ情報格納
  def save_project_detail_dependency_libraries(target_id, libraries)
    InputDependencyLibrary.where(input_project_id: target_id).delete_all
    libraries.each do |library|
      pj = InputDependencyLibrary.new(
        name: library.name,
        version: library.requirements,
        input_project_id: target_id
      )
      pj.save!
    end
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
      Rails.logger.info("fetch project detail branches #{project_id} (page: #{page})")
      res
    end

    fetch_projects_detail_with_rate_limit(
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
      Rails.logger.info("fetch project detail tags #{project_id} (page: #{page})")
      res
    end

    fetch_projects_detail_with_rate_limit(
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
      Rails.logger.info("fetch project detail trees #{project_id} #{sha} (page: #{page})")
      res
    end

    fetch_projects_detail_with_rate_limit(
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
      Rails.logger.info("fetch project detail contents #{project_id} #{sha} (page: #{page})")
      res
    end

    fetch_projects_detail_with_rate_limit(
      p
    )
  end

  # 週間コミット数の取得と格納
  # 過去12週の間に更新されていない場合はコミット数0とする
  def fetch_and_save_project_detail_weekly_commit_counts(target_id, github_item_id, github_updated_at)
    if github_updated_at > (Time.zone.today - 3.months).to_s
      weekly_commit_results = fetch_projects_detail_weekly_commit_counts_by_project_id(github_item_id)
    else
      weekly_commit_results = []
      12.times do |i|
        weekly_commit_results << { index: i, all: 0, owner: 0 }
      end
    end

    save_project_detail_weekly_commit_counts(target_id, weekly_commit_results)
  end

  # 指定したプロジェクトIDよりリポジトリ詳細情報(週間コミット数)取得
  def fetch_projects_detail_weekly_commit_counts_by_project_id(project_id)
    Rails.logger.info("fetch project detail contents #{project_id}")

    p = proc do |page|
      client = GithubClient.new(Settings.github_crawl_token)
      # 失敗率が高いため少し待ってから取得する
      sleep WEEKLY_COMMIT_COUNT_WAIT_TIME
      res = client.get_repositories_weekly_commit_counts_by_project_id(
        project_id,
        page: page
      )
      Rails.logger.info("fetch project #{project_id} (page: #{page})")
      res
    end

    fetch_projects_detail_with_rate_limit(
      p
    ).flatten
  end

  # 指定したプロジェクトの主キーを元に解析対象のリポジトリ詳細情報(コンテンツ)取得と格納
  def fetch_and_save_project_detail_contents(input_project_id)
    is_success = true
    project_information = InputProject.find(input_project_id)
    targets = InputTree.where(input_project_id: input_project_id)
    InputContent.where(input_project_id: input_project_id).delete_all

    targets.each do |target|
      is_target = InputTree.analyze_target?(target.path)
      Rails.logger.info("input_project_id=#{input_project_id};"\
                        "path=#{target.path};"\
                        "analyze_target=#{is_target}")
      next unless is_target
      if InputTree.gemfile?(target.path) || InputTree.readme?(target.path)
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
      elsif InputTree.gemspec?(target.path)
        Rails.logger.info('fetch project libraries information from rubygems '\
                          "#{project_information.github_item_id} #{target.path}")
        library_found, library_information, dependency_libraries = fetch_projects_detail_from_ruby_gem(
          project_information.name
        )
        if library_found
          save_library_information(
            input_project_id,
            library_information
          )
          save_project_detail_dependency_libraries(
            input_project_id,
            dependency_libraries
          )
        else
          Rails.logger.info("rubygems not found #{project_information.name}")
        end
      end
    end

    is_success
  end

  # API制限,リトライを考慮してデータ取得　
  def fetch_projects_detail_with_rate_limit(get_repositories_proc)
    results = []
    retry_count = 0
    page_count = 1

    loop do
      res = get_repositories_proc.call(page_count)
      if res.rate_limit_remaining <= 1
        # rate limit解除時間まで待つ 3秒ほど余裕を持たせる
        till_time = Time.zone.at(res.rate_limit_reset.to_i)
        Rails.logger.info("Rate limit exceeded. Waiting until #{till_time}")
        sleep_time = (till_time - Time.zone.now).ceil + 3
        sleep_time = 3 if sleep_time <= 0
        sleep sleep_time
      end
      if !res.is_success
        Rails.logger.info("fetch failed. Retry(retry count: #{retry_count})")
        if retry_count >= 5
          fail 'Retry Limit.'
        else
          retry_count += 1
          # Retry する場合 少し待つ
          sleep RETRY_WAIT_TIME
          redo
        end
      else
        retry_count = 0
        results << res.items
        if res.has_next_page
          page_count += 1
        else
          break
        end
      end
    end

    results
  end

  # リトライを考慮してRubyGemsからデータを取得
  def fetch_projects_detail_from_ruby_gem(name)
    results = []
    is_success = true
    retry_count = 0
    base_information = nil

    loop do
      client = RubyGemsClient.new
      res = client.get_ruby_gems_information_by_name(
        name
      )
      Rails.logger.info("fetch project #{name}")

      if res.not_found
        is_success = false
        break
      end

      if !res.is_success
        Rails.logger.info("fetch failed. Retry(retry count: #{retry_count})")
        if retry_count >= 5
          fail 'Retry Limit.'
        else
          retry_count += 1
          # Retry する場合 少し待つ
          sleep RETRY_WAIT_TIME
          redo
        end
      else
        retry_count = 0
        base_information = res.base_information
        results << res.items
        break
      end
    end

    [is_success, base_information, results.flatten]
  end
end
