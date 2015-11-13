object false

node(:status) { "success" }
child(@input_project, :root => "result", :object_root => false ){
  extends "api/input_projects/project"
  node(:gemfile) { @gemfile }
}
