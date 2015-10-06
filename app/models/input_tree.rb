# == Schema Information
#
# Table name: input_trees
#
#  id               :integer          not null, primary key
#  input_project_id :integer          not null
#  path             :string(255)      not null
#  type             :string(255)      not null
#  sha              :string(255)      not null
#  url              :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class InputTree < ActiveRecord::Base
  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
