# == Schema Information
#
# Table name: projects
#
#  id                 :integer          not null, primary key
#  is_incomplete      :boolean          default(TRUE), not null
#  github_item_id     :integer
#  name               :string(255)      not null
#  full_name          :string(255)
#  owner_id           :integer
#  owner_login_name   :string(255)      default(""), not null
#  owner_type         :string(30)       default(""), not null
#  github_url         :string(255)
#  is_fork            :boolean          default(FALSE), not null
#  github_description :text(65535)
#  github_created_at  :datetime
#  github_updated_at  :datetime
#  github_pushed_at   :datetime
#  homepage           :text(65535)
#  size               :integer          default(0), not null
#  stargazers_count   :integer          default(0), not null
#  watchers_count     :integer          default(0), not null
#  fork_count         :integer          default(0), not null
#  open_issue_count   :integer          default(0), not null
#  github_score       :string(255)      default(""), not null
#  language           :string(255)      default(""), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Project < ActiveRecord::Base
  # Relations
  has_many :project_dependencies, foreign_key: :project_from_id
  has_many :projects, through: :project_dependencies, source: :project_to
  has_many :project_branches, dependent: :destroy
  has_many :project_trees, dependent: :destroy
  has_many :project_tags, dependent: :destroy
  has_many :project_weekly_commit_counts, dependent: :destroy
  has_many :project_readmes, dependent: :destroy

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods

  # 引数として指定したgemを関連ライブラリとして保存
  def create_dependency_projects(gemfile_names)
    gemfile_names.each do |name|
      self
        .project_dependencies
        .find_or_initialize_by(library_name: name)
      # TODO: ライブラリ名からProjectIdに変換する処理を考える!
    end

    self.project_dependencies
  end
end
