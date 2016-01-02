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
      .find_by(name: gem_name)
      .try(:input_project)
      .try(:github_item_id)
  end

  # gem名からfull_nameを取得する
  def self.get_full_name_from_gem_name(gem_name)
    full_name = InputLibrary
                .where(InputLibrary.arel_table[:homepage_uri].matches('%/github.com/%'))
                .find_by(InputLibrary.arel_table[:homepage_uri].matches("%/#{gem_name}"))
                .try(:homepage_uri)

    if full_name.nil?
      full_name = InputLibrary
                  .where(InputLibrary.arel_table[:source_code_uri].matches('%/github.com/%'))
                  .find_by(InputLibrary.arel_table[:source_code_uri].matches("%/#{gem_name}"))
                  .try(:source_code_uri)
    end

    if full_name.present?
      full_name = full_name
                  .gsub('http://github.com/', '')
                  .gsub('https://github.com/', '')
    end

    full_name
  end

  # Methods
end
