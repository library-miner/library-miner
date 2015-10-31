# == Schema Information
#
# Table name: input_trees
#
#  id               :integer          not null, primary key
#  input_project_id :integer          not null
#  path             :string(255)      not null
#  file_type        :string(255)      not null
#  sha              :string(255)      not null
#  url              :string(255)
#  size             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class InputTree < ActiveRecord::Base

  COPYABLE_ATTRIBUTES = %i(
    path file_type sha url size
  )

  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
  # ファイル解析対象であるか判定
  def self.is_analize_target?(file_name)
    is_target = false

    # Gemfile
    is_target = true if file_name == 'Gemfile'

    # gemspec
    is_target = true if file_name.downcase =~ /.gemspec$/

    # readme
    is_target = true if file_name.downcase == 'readme.md' ||
      file_name.downcase == 'readme.rdoc'

    is_target
  end

  def self.is_gemfile?(file_name)
    file_name == 'Gemfile'
  end

  def self.is_gemspec?(file_name)
    file_name.downcase =~ /.gemspec$/
  end

  def self.is_readme?(file_name)
    file_name.downcase == 'readme.md' ||
      file_name.downcase == 'readme.rdoc'
  end
end
