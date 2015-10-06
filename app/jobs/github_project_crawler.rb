class GithubProjectCrawler < Base
  queue_as :github_project_crawler

  def perform(*_args)
  end
end
