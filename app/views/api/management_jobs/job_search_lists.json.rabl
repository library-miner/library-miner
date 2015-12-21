object false

node(:status) { "success" }
child(@job_lists, :root => "result", :object_root => false ){
  node(:id) { |p| p }
  node(:name) { |p| p }
}
