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
    input_library = InputLibrary
                    .find_by(name: gem_name)

    full_name = nil
    if input_library.present?
      # homepage_uriにgithubへのURLが記載されているか
      if input_library.homepage_uri.present?
        full_name = input_library.homepage_uri.match(/.+github.com.+/)
      end

      # homepage_uriにgithubへのURLが記載されているか
      if full_name.nil? && input_library.source_code_uri.present?
        full_name = input_library.source_code_uri.match(/.+github.com.+/)
      end
    end

    if full_name.present?
      full_name = full_name[0].to_s
      # 先頭のURLは取り除く
      full_name = full_name
                  .gsub('http://github.com/', '')
                  .gsub('https://github.com/', '')
      # full_nameの最後の/は取り除く
      if full_name[full_name.length - 1] == '/'
        full_name = full_name[0..full_name.length - 2]
      end
    end

    full_name
  end

  # Methods
end
