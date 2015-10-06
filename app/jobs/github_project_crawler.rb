# Githubから基本情報を取得するジョブ
#
# [即時実行]
#   GithubProjectClawler.new.perform(Date.new(2015,10,1), Date.new(2015,10,6))
class GithubProjectCrawler < Base
  queue_as :github_project_crawler

  def perform(date_from, date_to)
  end
end
