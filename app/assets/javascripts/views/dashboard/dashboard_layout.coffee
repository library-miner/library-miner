class Miner.Views.DashboardLayout extends Marionette.LayoutView
  template: HandlebarsTemplates['dashboard_layout']

  regions: {
    crawlStatus: "#crawl-status"
  }

  initCrawlStatus: ->
    @status = new Miner.Models.CrawlStatus()
    @crawlStatusView = new Miner.Views.CrawlStatusView(model: @status)
    @crawlStatus.show(@crawlStatusView)

    @status.fetch(reset: true)


  onRender: ->
    @initCrawlStatus()

