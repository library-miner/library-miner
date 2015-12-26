class Base < ActiveJob::Base
  def exec_job(&_block)
    yield
  end

  after_enqueue do |job|
    ManagementJob.job_enqueue(job_id, job.class.name)
  end

  before_perform do |job|
    ManagementJob.job_before_perform(job_id, job.class.name)
  end

  after_perform do |job|
    ManagementJob.job_after_perform(job_id, job.class.name)
  end

  rescue_from(Exception) do |exception|
    ManagementJob.job_error(job_id, exception.message)
    raise exception
  end
end
