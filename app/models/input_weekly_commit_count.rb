# == Schema Information
#
# Table name: input_weekly_commit_counts
#
#  id               :integer          not null, primary key
#  input_project_id :integer          not null
#  index            :integer          not null
#  all_count        :integer          not null
#  owner_count      :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class InputWeeklyCommitCount < ActiveRecord::Base
  # Relations
  belongs_to :input_project

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
