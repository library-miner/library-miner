# == Schema Information
#
# Table name: management_jobs
#
#  id            :integer          not null, primary key
#  job_id        :string(255)
#  job_name      :string(255)
#  error_message :text(65535)
#  started_at    :datetime
#  ended_at      :datetime
#  job_status    :integer          not null
#  created_at    :datetime
#  updated_at    :datetime
#

class ManagementJob < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  # Relations
  belongs_to_active_hash :job_status

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
  def self.job_enqueue(job_id, job_name)
    job = ManagementJob.find_or_initialize_by(
      job_id: job_id
    )
    job.attributes = {
      job_id: job_id,
      job_name: job_name,
      job_status: JobStatus::WAITING
    }
    job.save!
  end

  def self.job_before_perform(job_id, job_name)
    job = ManagementJob.find_or_initialize_by(
      job_id: job_id
    )
    job.attributes = {
      job_id: job_id,
      job_name: job_name,
      job_status: JobStatus::EXECUTING,
      started_at: DateTime.now
    }
    job.save!
  end

  def self.job_after_perform(job_id, job_name)
    job = ManagementJob.find_or_initialize_by(
      job_id: job_id
    )
    job.attributes = {
      job_id: job_id,
      job_name: job_name,
      job_status: JobStatus::COMPLETE,
      ended_at: DateTime.now
    }
    job.save!
  end

  def self.job_error(job_id, message)
    job = ManagementJob.find_or_initialize_by(
      job_id: job_id
    )
    job.attributes = {
      job_id: job_id,
      job_status: JobStatus::ERROR,
      ended_at: DateTime.now,
      error_message: message
    }
    job.save!
  end
end
