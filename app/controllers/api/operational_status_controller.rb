class Api::OperationalStatusController < ApplicationController

  # プロジェクトクロール状況
  def projects_crawl_status
    @all = InputProject.count

    @waiting = InputProject
    .where(crawl_status: CrawlStatus::WAITING)
    .count

    @inprogress = InputProject
    .where(crawl_status: CrawlStatus::IN_PROGRESS)
    .count

    @done = InputProject
    .where(crawl_status: CrawlStatus::DONE)
    .count

    @analyze_done = InputProject
    .where(crawl_status: CrawlStatus::ANALYZE_DONE)
    .count

    @error = InputProject
    .where(crawl_status: CrawlStatus::ERROR)
    .count

    @analyze_error = InputProject
    .where(crawl_status: CrawlStatus::ANALYZE_ERROR)
    .count
  end

  # 収集中一覧
  def crawl_inprogress
    @input_projects = InputProject
    .where(crawl_status: CrawlStatus::IN_PROGRESS)
    .group(:client_node_id)
    .count
  end

  # プロジェクト解析状況
  def projects_analyze_status
    @all = Project.count

    @incompleted = Project
    .incompleted
    .count

    @completed = Project
    .completed
    .count

    @github_id_nothing = Project
    .incompleted
    .where(github_item_id: nil)
    .where(full_name: !nil)
    .count

    @full_name_nothing = Project
    .incompleted
    .where(full_name: nil)
    .count
  end

end

