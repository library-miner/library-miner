FactoryGirl.define do
  factory :project_tree do
    project_id 1
    path 'test'
    file_type 'blob'
    sha 'aaaaabbbbbccccc'
  end
end
