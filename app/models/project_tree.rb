# == Schema Information
#
# Table name: project_trees
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  path       :string(255)      not null
#  file_type  :string(255)      not null
#  sha        :string(255)      not null
#  url        :string(255)
#  size       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectTree < ActiveRecord::Base
  # Relations
  belongs_to :project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
  # トップ階層にgemspecが存在するか
  def self.include_gemspec?(project_id)
    result = false
    trees = ProjectTree
            .where(ProjectTree.arel_table[:path].matches('%.gemspec'))
            .where(project_id: project_id)

    trees.each do |tree|
      p = tree.path.split('/')
      if tree.file_type == 'blob' && InputTree.gemspec?(p[0])
        result = true
      end
    end
    result
  end
end
