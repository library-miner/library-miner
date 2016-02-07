# WebAPI
module Api
  # Project 情報 Web連携
  class ProjectExportController < ApplicationController
    def index
      @projects = Project.page(2)
    end

    def export_ready

    end

    def export_end

    end
  end
end
