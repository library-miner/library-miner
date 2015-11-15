class Miner.Controllers.MinerController extends Marionette.Object
  initialize: () ->
    Miner.Application.addRegions(
      mainForm: '#main-form'
    )

  index: ->
    @dashboardLayout = new Miner.Views.DashboardLayout()
    Miner.Application.mainForm.show(@dashboardLayout)

