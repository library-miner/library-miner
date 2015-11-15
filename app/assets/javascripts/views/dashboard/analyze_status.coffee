class Miner.Views.AnalyzeStatusView extends Marionette.ItemView
  template: HandlebarsTemplates['analyze_status']

  initialize: ->
    @listenTo(@model, 'change', @render)

  onRender: ->
    @stickit()
    @
