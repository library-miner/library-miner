# == Schema Information
#
# Table name: input_contents
#
#  id               :integer          not null, primary key
#  input_project_id :integer          not null
#  path             :string(255)      not null
#  sha              :string(255)      not null
#  url              :string(255)      not null
#  content          :text(65535)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class InputContent < ActiveRecord::Base
  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
