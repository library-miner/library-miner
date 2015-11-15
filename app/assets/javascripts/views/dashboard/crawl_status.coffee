class Miner.Views.CrawlStatusView extends Marionette.ItemView
  template: HandlebarsTemplates['crawl_status']

  initialize: ->
    @listenTo(@model, 'change', @render)

  onRender: ->
    @stickit()
    @
