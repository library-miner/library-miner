class Miner.Views.JobStatusView extends Marionette.ItemView
  template: HandlebarsTemplates['job_status']

  initialize: ->
    @listenTo(@model, 'change', @render)

  onRender: ->
    @stickit()
    @
