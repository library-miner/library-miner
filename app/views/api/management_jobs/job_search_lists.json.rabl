object false

node(:status) { "success" }
child(@job_lists, :root => "result", :object_root => false ){
  node(:id) { |p| p.job_name }
  node(:name) { |p| p.job_name }
}
