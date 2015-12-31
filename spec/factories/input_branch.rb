FactoryGirl.define do
  factory :input_branch do
    input_project_id 1
    name 'master'
    sha 'aaaaabbbbbccccc'
    url 'http://test.com/'
  end

end
