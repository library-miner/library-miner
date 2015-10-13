# == Schema Information
#
# Table name: input_projects
#
#  id                 :integer          not null, primary key
#  crawl_status_id    :integer          default(0), not null
#  github_item_id     :integer          not null
#  client_node_id     :integer
#  name               :string(255)      not null
#  full_name          :string(255)      not null
#  owner_id           :integer          not null
#  owner_login_name   :string(255)      not null
#  owner_type         :string(30)       not null
#  github_url         :string(255)      not null
#  is_fork            :boolean          default(FALSE), not null
#  github_description :text(65535)
#  github_created_at  :datetime         not null
#  github_updated_at  :datetime         not null
#  github_pushed_at   :datetime         not null
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

class InputProject < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  COPYABLE_ATTRIBUTES = %i(
    github_item_id name full_name owner_id owner_login_name owner_type
    github_url is_fork github_description github_created_at
    github_updated_at github_pushed_at homepage
    size stargazers_count watchers_count fork_count open_issue_count
    github_score language
  )

  # Relations
  belongs_to_active_hash :crawl_status
  has_many :input_branches, dependent: :destroy
  has_many :input_trees, dependent: :destroy
  has_many :input_contents, dependent: :destroy
  has_many :input_tags, dependent: :destroy
  has_many :input_weekly_commit_counts, dependent: :destroy
  has_many :input_dependency_libraries, dependent: :destroy
  has_one :input_library, dependent: :destroy

  # Validations

  # Scopes
  scope :crawled, -> do
    where(crawl_status_id: CrawlStatus::DONE.id)
  end

  # Delegates

  # Class Methods

  # 未処理の情報を取得
  # 取得上限の指定が必要
  # 別クローラが同じプロジェクトを解析しない考慮あり
  def self.get_project_detail_crawl_target(max_count)
    targets = InputProject
      .where(crawl_status: CrawlStatus::WAITING)
      .order(:updated_at)
      .limit(max_count)

    targets.each do |target|
      target.crawl_status = CrawlStatus::IN_PROGRESS
      target.save!
    end

    InputProject.where(crawl_status: CrawlStatus::IN_PROGRESS)
  end


  # Methods

  # TODO: FIXME なんかまずそう Gemfileは本当に一つ?
  def gemfile
    self.input_contents.find_by(path: "Gemfile")
  end
end
