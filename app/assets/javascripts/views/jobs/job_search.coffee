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
        defaultOption:
          label: '全て'
          value: null
    }
    '#job-status': {
      observe: 'jobStatus'
    }
    '.job-started-at': 'jobStartedAt'
    '.job-ended-at': 'jobEndedAt'
    '.job-from': 'jobFrom'
    '.job-to': 'jobTo'
  }

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

  onRender: ->
    @initJobSearchList()
    @stickit()
    @

  onAttach: ->
    @initPlugin()
    @
