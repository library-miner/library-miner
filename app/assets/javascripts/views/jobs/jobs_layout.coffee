class Miner.Views.JobsLayout extends Marionette.LayoutView
  template: HandlebarsTemplates['jobs_layout']

  regions: {
    searchRegion: "#search-region"
    listRegion: "#list-region"
  }

  initSearch: ->
    @jobSearch = new Miner.Models.JobSearch()
    @jobSearchView = new Miner.Views.JobSearchView(model: @jobSearch)
    @searchRegion.show(@jobSearchView)

  onRender: ->
    @initSearch()

