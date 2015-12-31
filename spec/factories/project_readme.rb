FactoryGirl.define do
  factory :project_readme do
    project_id 1
    path 'readme.md'
    sha 'aaaaabbbbbccccc'
    content "readme"
  end

end
