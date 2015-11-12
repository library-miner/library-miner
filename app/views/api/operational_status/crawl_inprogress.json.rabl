node(:status) { "success" }
child @input_projects => :result do
  node(:client_id) { |m| m[0] }
  node(:count) { |m| m[1] }
end
