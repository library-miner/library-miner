FactoryGirl.define do
  factory :project_branch do
    project_id 1
    name 'master'
    sha 'aaaaabbbbbccccc'
    url 'http://test.com/'
  end
end
