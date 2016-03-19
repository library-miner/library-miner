# == Schema Information
#
# Table name: project_readmes
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  path       :string(255)      not null
#  sha        :string(255)      not null
#  content    :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectReadme < ActiveRecord::Base
  include AttributeScrubbable
  include JsonScrubbable

  # Relations
  belongs_to :project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
