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
  def self.is_analyze_target?(file_name)
    is_target = false

    # Gemfile
    is_target = true if self.is_gemfile?(file_name)

    # gemspec
    is_target = true if self.is_gemspec?(file_name)

    # readme
    is_target = true if self.is_readme?(file_name)

    is_target
  end

  def self.is_gemfile?(file_name)
    file_name == 'Gemfile'
  end

  def self.is_gemspec?(file_name)
    file_name.downcase =~ /.gemspec$/
  end

  def self.is_readme?(file_name)
    # readme.rdoc は整備率が低いため取得しない
    file_name.downcase == 'readme.md'
  end

  def self.check_analyze_target_is_update?(github_item_id)
    is_update = false

    project_info = Project.where(github_item_id: github_item_id).first
    input_project_info = InputProject.where(github_item_id: github_item_id).first

    if project_info.present? && input_project_info.present?

      project_trees = project_info.project_trees
      input_trees = input_project_info.input_trees

      input_trees.each do |tree|
        if InputTree.is_analyze_target?(tree.path)
          p_tree = ProjectTree.where(
            project_id: project_info.id,
            path: tree.path
          ).first
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
      end

      if is_update != true
        project_trees.each do |tree|
          if InputTree.is_analyze_target?(tree.path)
            i_tree = InputTree.where(
              input_project_id: input_project_info.id,
              path: tree.path
            ).first
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
      end

    else
      is_update = true
    end

    is_update
  end
end
