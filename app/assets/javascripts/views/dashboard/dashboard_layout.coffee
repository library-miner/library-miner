class Miner.Views.DashboardLayout extends Marionette.LayoutView
  template: HandlebarsTemplates['dashboard_layout']

  regions: {
    crawlStatus: "#crawl-status"
  }

  initCrawlStatus: ->
    crawlStatus = new Miner.Models.CrawlStatus()
    crawlStatusView = new Miner.Views.CrawlStatusView(model: crawlStatus)
    @crawlStatus.show(crawlStatusView)

    crawlStatus.fetch(reset: true)


  onRender: ->
    @initCrawlStatus()

