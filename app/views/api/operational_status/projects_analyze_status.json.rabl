object false

node(:status) { "success" }
child :crawl_status do
  node(:all) { @all }
  node(:incompleted) { @incompleted }
  node(:completed) { @completed }
  node(:githubIdNothing) { @github_id_nothing }
  node(:fullNameNothing) { @full_name_nothing }
end
