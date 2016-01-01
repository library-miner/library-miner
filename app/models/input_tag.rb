# == Schema Information
#
# Table name: input_tags
#
#  id               :integer          not null, primary key
#  input_project_id :integer          not null
#  name             :string(255)      not null
#  sha              :string(255)      not null
#  url              :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class InputTag < ActiveRecord::Base
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
end
