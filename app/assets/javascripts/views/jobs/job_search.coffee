class Miner.Views.JobSearchView extends Marionette.ItemView
  template: HandlebarsTemplates['job_search']

  initialize: ->
    @listenTo(@model, 'change', @render)

  onRender: ->
    @stickit()
    @
