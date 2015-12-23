class Api::ManagementJobsController < ApplicationController
  before_action :search_params, only: []

  def index
    @job = Search::ManagementJob.new(search_params)
    @jobs = @job
      .matches
      .order(created_at: :desc)
  end

  def job_search_lists
    @job_lists = ManagementJob.select(:job_name).uniq
  end

  private

  def search_params
    rp = params.permit(
      Search::ManagementJob::ATTRIBUTES.map {
        |k| k.to_s.camelize(:lower).to_sym
      }
    )
    Hash[rp.map { |k, v| [k.underscore, v] }]
  end
end

