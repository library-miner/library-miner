class Miner.Views.JobSearchView extends Marionette.LayoutView
  template: HandlebarsTemplates['job_search']

  regions: {
    jobSearchList: "#job-search-list"
  }

  bindings: {
    '#job-select': {
      observe: 'job'
      selectOptions:
        collection: ->
          @jobSearchLists
        labelPath: 'id'
        valuePath: 'name'
    }
    '#job-status': {
      observe: 'jobStatus'
    }
  }

  initialize: ->
    @listenTo(@model, 'change', @log)

  log: ->
    console.log @model.attributes

  initJobSearchList: ->
    @jobSearchLists = new Miner.Collections.JobSearchLists()
    @jobSearchLists.fetch()

  onRender: ->
    @initJobSearchList()
    @stickit()
    @
