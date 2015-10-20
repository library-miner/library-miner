# == Schema Information
#
# Table name: project_trees
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  path       :string(255)      not null
#  file_type  :string(255)      not null
#  sha        :string(255)      not null
#  url        :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectTree < ActiveRecord::Base
  # Relations
  belongs_to :project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
