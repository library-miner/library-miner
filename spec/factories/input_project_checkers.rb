# == Schema Information
#
# Table name: input_project_checkers
#
#  id         :integer          not null, primary key
#  crawl_date :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :input_project_checker do
    crawl_date '2015-01-01'
  end
end
