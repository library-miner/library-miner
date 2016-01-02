# == Schema Information
#
# Table name: input_project_checkers
#
#  id         :integer          not null, primary key
#  crawl_date :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class InputProjectChecker < ActiveRecord::Base
  # Relations

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods

  # 収集日格納
  def self.insert_crawl_date(crawl_date)
    d = Date.parse(crawl_date.to_s)
    pc = InputProjectChecker.find_or_initialize_by(
      crawl_date: d
    )
    pc.attributes = {
      crawl_date: d
    }
    pc.save!
  end

  # 期間内で初回基本情報収集抜け一覧を返却する
  def self.check_crawl(from, to)
    begin
      from_d = Date.parse(from)
      to_d = Date.parse(to)
    rescue
      return []
    end

    results = []
    (from_d..to_d).each do |d|
      results << d.to_s if InputProjectChecker.where(
        crawl_date: d
      ).count == 0
    end
    results
  end
end
