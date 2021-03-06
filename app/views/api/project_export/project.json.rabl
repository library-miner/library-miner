attribute :id
attribute :is_incomplete
attribute :github_item_id
attribute :name
attribute :full_name
attribute :owner_id
attribute :owner_login_name
attribute :owner_type
attribute :github_url
attribute :is_fork
attribute :github_description
attribute :github_created_at
attribute :github_updated_at
attribute :github_pushed_at
attribute :homepage
attribute :size
attribute :stargazers_count
attribute :watchers_count
attribute :fork_count
attribute :open_issue_count
attribute :github_score
attribute :language
attribute :project_type_id
child :project_readmes ,:object_root => false do
  extends "api/project_export/read_me"
end
child :project_dependencies, :object_root => false do
  extends "api/project_export/project_dependency"
end
