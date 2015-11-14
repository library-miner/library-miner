class Api::InputProjectsController < ApplicationController
  before_action :set_input_project, only: [:show]

  def show
    @gemfile = @input_project.gemfile.try(:content)
  end

  # 収集失敗リスト
  def crawl_errors
    @input_projects = InputProject
    .where(crawl_status: CrawlStatus::ERROR)
  end

 # 解析失敗リスト
  def analyze_errors
    @input_projects = InputProject
    .where(crawl_status: CrawlStatus::ANALYZE_ERROR)
  end

  private

  def set_input_project
    @input_project = InputProject.find(params[:id])
  end
end

