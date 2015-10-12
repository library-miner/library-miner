# == Schema Information
#
# Table name: input_libraries
#
#  id               :integer          not null, primary key
#  input_project_id :integer
#  name             :string(255)      not null
#  version          :string(255)      not null
#  source_code_uri  :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class InputLibrary < ActiveRecord::Base
  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
