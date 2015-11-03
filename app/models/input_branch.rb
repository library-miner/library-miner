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
  )

  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
  def self.check_master_branch_is_update?(github_item_id, master_branch_sha)
    is_update = true
    p = Project.where(github_item_id: github_item_id).first
    if p.present?
      b = ProjectBranch.where(project_id: p.id, name: 'master').first
      if b.sha == master_branch_sha
        is_update = false
      end
    end
    is_update
  end
end
