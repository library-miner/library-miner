FactoryGirl.define do
  factory :project do
    github_item_id 123456789123456789
    name 'test'
    full_name 'owner/test'
    owner_id 12345678
    owner_login_name 'owner'
    owner_type 'User'
    github_url 'http://test.com'
    is_fork false
    github_created_at '2015-01-01 0:00:00'
    github_updated_at '2015-01-01 0:00:00'
    github_pushed_at '2015-01-01 0:00:00'
    size 123
    stargazers_count 777
    watchers_count 321
    fork_count 456
    open_issue_count 789
    language 'ruby'
  end

end
