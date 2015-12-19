object false

node(:status) { "success" }
child :job_status do
  node(:all) { @all }
  node(:waiting) { @waiting }
  node(:executing) { @executing }
  node(:complete) { @complete }
  node(:error) { @error }
end
