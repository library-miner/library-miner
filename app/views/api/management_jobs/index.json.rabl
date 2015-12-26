object false

node(:status) { "success" }
child(@jobs, :root => "result", :object_root => false ){
  attribute :job_id => "jobId"
  attribute :job_name => "jobName"
  node(:jobStatus) { |p| p.job_status.name }
  attribute :error_message => "errorMessage"
  attribute :started_at => "startedAt"
  attribute :ended_at => "endedAt"
  attribute :created_at => "createdAt"
  attribute :updated_at => "updatedAt"
}
