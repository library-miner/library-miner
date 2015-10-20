# == Schema Information
#
# Table name: project_branches
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  name       :string(255)      not null
#  sha        :string(255)      not null
#  url        :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectBranch < ActiveRecord::Base
  # Relations
  belongs_to :project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
