# WebAPI
module Api
  # Project 情報 Web連携
  class ProjectExportController < ApplicationController
    PER_PAGE = 100

    def index
      @total_page = total_page
      @page = params[:page]
      @page = 1 if @page.nil?
      @projects = Project
                  .in_progress_export
                  .page(@page)
                  .per(PER_PAGE)
    end

    def export_ready
      @total_count = Project.export_ready(params[:count])
      @total_page = total_page
    end

    def export_end
      @total_count = Project.in_progress_export.count
      Project.export_end
    end

    private

    def total_page
      total_count = Project.in_progress_export.count
      total_page = 0
      if total_count > 0
        total_page = 1 + (total_count / PER_PAGE).to_i
      end
      total_page
    end
  end
end
