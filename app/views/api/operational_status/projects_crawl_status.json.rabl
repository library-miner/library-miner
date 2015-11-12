object false

node(:status) { "success" }
child :crawl_status do
  node(:all) { @all }
  node(:waiting) { @waiting }
  node(:inprogress) { @inprogress }
  node(:done) { @done }
  node(:analyzeDone) { @analyze_done }
  node(:error) { @error }
  node(:analyzeError) { @analyze_error }
end
