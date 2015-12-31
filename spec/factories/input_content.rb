FactoryGirl.define do
  factory :input_content do
    input_project_id 1
    path 'http://test.com/'
    sha 'aaaaabbbbbccccc'
    content "source 'https://rubygems.org'
             gem 'sass-rails',   '4.0.5'"
  end

end
