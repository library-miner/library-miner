# == Schema Information
#
# Table name: input_dependency_libraries
#
#  id               :integer          not null, primary key
#  input_project_id :integer          not null
#  name             :string(255)      not null
#  version          :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class InputDependencyLibrary < ActiveRecord::Base
  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
