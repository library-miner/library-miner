# == Schema Information
#
# Table name: project_dependencies
#
#  id              :integer          not null, primary key
#  project_from_id :integer          not null
#  project_to_id   :integer
#  library_name    :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ProjectDependency < ActiveRecord::Base
end
