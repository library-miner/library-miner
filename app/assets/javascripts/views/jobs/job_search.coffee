class Miner.Views.JobSearchView extends Marionette.LayoutView
  template: HandlebarsTemplates['job_search']

  regions: {
    jobSearchList: "#job-search-list"
  }

  initialize: ->
    @listenTo(@model, 'change', @render)

  initJobSearchList: ->
    jobSearchLists = new Miner.Collections.JobSearchLists()
    selectItems = new Miner.Views.SelectItemsView(collection: jobSearchLists)
    @jobSearchList.show(selectItems)
    jobSearchLists.fetch(reset: true)

  onRender: ->
    @initJobSearchList()
    @stickit()
    @
