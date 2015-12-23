class Miner.Views.JobSearchView extends Marionette.LayoutView
  template: HandlebarsTemplates['job_search']

  regions:
    jobSearchList: "#job-search-list"
    jobResultRegion: "#job-result-region"

  events:
    'click #search-button': 'searchJob'

  bindings:
    '#job-select':
      observe: 'jobName'
      selectOptions:
        collection: ->
          @jobSearchLists
        labelPath: 'id'
        valuePath: 'name'
        defaultOption:
          label: '全て'
          value: null
    '#job-status':
      observe: 'jobStatus'
    '.job-started-at': 'jobStartedAt'
    '.job-ended-at': 'jobEndedAt'
    '.job-from': 'From'
    '.job-to': 'To'

  initialize: ->
    @listenTo(@model, 'change', @log)

  log: ->
    console.log @model.attributes

  initJobSearchList: ->
    @jobSearchLists = new Miner.Collections.JobSearchLists()
    @jobSearchLists.fetch()

  initPlugin: ->
    $('#job-started-at').daterangepicker({
      timePicker: true
      timePickerIncrement: 5
      format: 'YYYY/MM/DD HH:mm'
      singleDatePicker: true
    })
    $('#job-ended-at').daterangepicker({
      timePicker: true
      timePickerIncrement: 5
      format: 'YYYY/MM/DD HH:mm'
      singleDatePicker: true
    })
    $('#job-from').daterangepicker({
      timePicker: true
      timePickerIncrement: 5
      format: 'YYYY/MM/DD HH:mm'
      singleDatePicker: true
    })
    $('#job-to').daterangepicker({
      timePicker: true
      timePickerIncrement: 5
      format: 'YYYY/MM/DD HH:mm'
      singleDatePicker: true
    })

  searchJob: ->
    jobResults = new Miner.Collections.Jobs()
    jobResultView = new Miner.Views.JobResultsView(collection: jobResults)
    @jobResultRegion.show(jobResultView)

    jobResults.fetch(
      reset: true
      data:
        jobName: @model.get('jobName')
        jobStatus: @model.get('jobStatus')
        jobStartedAt: @model.get('jobStartedAt')
        jobEndedAt: @model.get('jobEndedAt')
        from: @model.get('From')
        to: @model.get('To')
    )

  onRender: ->
    @initJobSearchList()
    @stickit()
    @

  onAttach: ->
    @initPlugin()
    @
