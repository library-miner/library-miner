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
  scope :incompleted, -> do
    where(is_incomplete: true)
  end
  # Delegates

  # Class Methods

  # プロジェクトが完全であるかチェックする
  # 依存ライブラリが全てプロジェクトIDと紐付いている
  # かつ project の github_item_idがある場合
  # プロジェクトは完全と見なす
  # なお、依存ライブラリ側のgithub_item_idがなくとも完全と見なす
  def check_completed?
    completed = true
    self.project_dependencies.each do |dependency|
      if dependency.project_to_id.nil?
        completed = false
      end
    end
    if self.github_item_id.nil?
      completed = false
    end
    completed
  end
  # Methods

  # 引数として指定したgemを関連ライブラリとして保存
  def create_dependency_projects(gemfile_names)
    # FIXME: ライブラリが削除された場合は考慮されているのか？
    # FIXME: Version情報も格納したい
    gemfile_names.each do |name|
      self
        .project_dependencies
        .find_or_initialize_by(library_name: name)
      # TODO: ライブラリ名からProjectIdに変換する処理を考える!
    end

    self.project_dependencies
  end

  # 関連gemの情報がprojectにない場合、プロジェクト情報を作成
  def create_project_from_dependency(gemfile_name)
    gemfile_name.each do |name|
      if Project.where(name: name).first.nil?
        project = Project.new(
          name: name
        )
        project.save
      end
    end
  end
end
