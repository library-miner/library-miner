# == Schema Information
#
# Table name: input_libraries
#
#  id               :integer          not null, primary key
#  input_project_id :integer
#  name             :string(255)      not null
#  version          :string(255)
#  homepage_uri     :string(255)
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

  # gem名からgithub_item_idを取得する
  def self.get_github_item_id_from_gem_name(gem_name)
    InputLibrary
    .where(name: gem_name)
    .first
    .try(:input_project)
    .try(github_item_id)
  end

  # Methods
end
