module Search
  class ManagementJob < Search::Base
    ATTRIBUTES = %i(
      job_name
      job_status
      started_at
      ended_at
      from
      to
    )
    attr_accessor(*ATTRIBUTES)

    def matches
      t = ::ManagementJob.arel_table
      results = ::ManagementJob.all

      results = results.where(contains(t[:job_name], job_name)) if job_name.present?
      results = results.where(t[:job_status_id].eq(job_status)) if job_status.present?
      results = results.where(t[:started_at].gteq(started_at)) if started_at.present?
      results = results.where(t[:ended_at].lteq(ended_at)) if ended_at.present?
      results = results.where(t[:created_at].gteq(from)) if from.present?
      results = results.where(t[:created_at].lteq(to)) if to.present?
      results
    end
  end
end
