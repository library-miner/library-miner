class Api::OperationalStatusController < ApplicationController

  # プロジェクトクロール状況
  def projects_crawl_status
    @all = InputProject.count

    @waiting = InputProject
    .where(crawl_status: CrawlStatus::WAITING)
    .count

    @in_progress = InputProject
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

end

