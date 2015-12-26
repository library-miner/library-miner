class Miner.Controllers.MinerController extends Marionette.Object
  initialize: () ->
    Miner.Application.addRegions(
      mainForm: '#main-form'
    )

  index: ->
    @dashboardLayout = new Miner.Views.DashboardLayout()
    Miner.Application.mainForm.show(@dashboardLayout)

  jobs_index: ->
    @jobsLayout = new Miner.Views.JobsLayout()
    Miner.Application.mainForm.show(@jobsLayout)
