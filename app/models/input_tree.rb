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
  ).freeze

  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
  # ファイル解析対象であるか判定
  def self.analyze_target?(file_name)
    is_target = false

    # Gemfile
    is_target = true if self.gemfile?(file_name)

    # gemspec
    is_target = true if self.gemspec?(file_name)

    # readme
    is_target = true if self.readme?(file_name)

    is_target
  end

  def self.gemfile?(file_name)
    file_name == 'Gemfile'
  end

  def self.gemspec?(file_name)
    file_name.downcase =~ /.gemspec$/
  end

  def self.readme?(file_name)
    # readme.rdoc は整備率が低いため取得しない
    file_name.casecmp('readme.md').zero?
  end

  def self.check_analyze_target_is_update?(github_item_id)
    is_update = false

    project_info = Project.find_by(github_item_id: github_item_id)
    input_project_info = InputProject.find_by(github_item_id: github_item_id)

    if project_info.present? && input_project_info.present?

      project_trees = project_info.project_trees
      input_trees = input_project_info.input_trees

      input_trees.each do |tree|
        next unless InputTree.analyze_target?(tree.path)
        p_tree = ProjectTree.find_by(
          project_id: project_info.id,
          path: tree.path
        )
        if p_tree.present?
          if p_tree.sha != tree.sha
            is_update = true
            break
          end
        else
          is_update = true
          break
        end
      end

      if is_update != true
        project_trees.each do |tree|
          next unless InputTree.analyze_target?(tree.path)
          i_tree = InputTree.find_by(
            input_project_id: input_project_info.id,
            path: tree.path
          )
          if i_tree.present?
            if i_tree.sha != tree.sha
              is_update = true
              break
            end
          else
            is_update = true
            break
          end
        end
      end

    else
      is_update = true
    end

    is_update
  end
end
