object false

node(:status) { "success" }
child(@projects, :root => "result", :object_root => false ){
  extends "api/project_export/project"
}
