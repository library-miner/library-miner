# == Schema Information
#
# Table name: input_branches
#
#  id               :integer          not null, primary key
#  input_project_id :integer          not null
#  name             :string(255)      not null
#  sha              :string(255)      not null
#  url              :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class InputBranch < ActiveRecord::Base
  COPYABLE_ATTRIBUTES = %i(
    name sha url
  ).freeze

  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
  def self.check_master_branch_is_update?(github_item_id, master_branch_sha, default_branch)
    is_update = true
    p = Project.find_by(github_item_id: github_item_id)
    if p.present?
      b = ProjectBranch.find_by(project_id: p.id, name: default_branch)
      is_update = false if b.sha == master_branch_sha
    end
    is_update
  end
end
