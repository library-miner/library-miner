class Miner.Controllers.MinerController extends Marionette.Object
  initialize: () ->
    Miner.Application.addRegions(
      mainForm: '#main-form'
    )

  index: ->
    @status = new Miner.Models.CrawlStatus()
    @dashBoardView = new Miner.Views.DashBoardView(model: @status)
    Miner.Application.mainForm.show(@dashBoardView)

    @status.fetch(reset: true)


