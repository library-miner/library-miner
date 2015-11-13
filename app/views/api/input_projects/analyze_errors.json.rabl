object false

node(:status) { "success" }
child(@input_projects, :root => "result", :object_root => false ){
  extends "api/input_projects/project"
}
