# == Schema Information
#
# Table name: project_weekly_commit_counts
#
#  id          :integer          not null, primary key
#  project_id  :integer          not null
#  index       :integer          not null
#  all_count   :integer          not null
#  owner_count :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProjectWeeklyCommitCount < ActiveRecord::Base
  # Relations
  belongs_to :project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
