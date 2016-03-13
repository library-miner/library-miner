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
#  project_type_id    :integer          default(0), not null
#  export_status_id   :integer          default(0), not null
#  exported_at        :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Project < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  # Relations
  belongs_to_active_hash :project_type
  belongs_to_active_hash :export_status
  has_many :project_dependencies, foreign_key: :project_from_id, dependent: :destroy
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

  scope :completed, -> do
    where(is_incomplete: false)
  end

  scope :in_progress_export, -> do
    where(export_status: ExportStatus::IN_PROGRESS)
  end

  scope :wait_export, -> do
    where(export_status: ExportStatus::WAITING)
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
    project_dependencies.each do |dependency|
      completed = false if dependency.project_to_id.nil?
    end
    completed = false if github_item_id.nil?
    completed
  end
  # Methods

  # 引数として指定したgemを関連ライブラリとして保存
  def create_dependency_projects(gemfile_names)
    gemfile_names.each do |name|
      project_dependencies
        .find_or_initialize_by(library_name: name)
    end
    # 過去に存在したが、現在はないライブラリは削除する
    project_dependencies.each do |pd|
      pd.delete unless gemfile_names.include?(pd.library_name)
    end
    project_dependencies
  end

  # 関連gemの情報がprojectにない場合、プロジェクト情報を作成
  def create_project_from_dependency(gemfile_name)
    gemfile_name.each do |name|
      next unless Project.find_by(name: name).nil?
      project = Project.new(
        name: name
      )
      project.save
    end
  end

  def get_project_type
    gem_include = ProjectTree.include_gemspec?(self.id)
    if gem_include
      ProjectType::RUBYGEM
    else
      ProjectType::PROJECT
    end
  end

  # Web連携準備
  # Export Statusを1(連携中)にする
  def self.export_ready(count)
    count = 0 if count.nil?
    Project.where(export_status: ExportStatus::WAITING)
           .limit(count)
           .update_all(export_status_id: ExportStatus::IN_PROGRESS)
    Project.in_progress_export.count
  end

  # Web連携終了
  # 連携中のステータスを2(連携済み)にする
  def self.export_end
    Project.where(export_status: ExportStatus::IN_PROGRESS)
           .update_all(
             export_status_id: ExportStatus::DONE,
             exported_at: Time.zone.now)
  end
end
