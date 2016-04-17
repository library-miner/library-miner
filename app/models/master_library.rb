# == Schema Information
#
# Table name: master_libraries
#
#  id            :integer          not null, primary key
#  project_to_id :integer
#  library_name  :string(255)      not null
#  status_id     :integer          default(10), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class MasterLibrary < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  # Relations
  belongs_to_active_hash :general_status
  belongs_to :project_to, class_name: 'Project'
  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
