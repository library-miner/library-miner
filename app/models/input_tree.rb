# == Schema Information
#
# Table name: input_trees
#
#  id               :integer          not null, primary key
#  input_project_id :integer          not null
#  path             :string(255)      not null
#  file_type        :string(255)      not null
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
  # ファイル解析対象であるか判定
  def self.is_analize_target?(file_name)
    is_target = false

    # Gemfile
    if file_name == "Gemfile"
      is_target = true
    end

    # gemspec
    if file_name.downcase =~ /.gemspec$/
      is_target = true
    end

    is_target
  end

  def self.is_gemfile?(file_name)
    file_name == "Gemfile"
  end
end
