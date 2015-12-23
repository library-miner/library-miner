class Miner.Views.JobResultsView extends Marionette.CompositeView
  tagName: 'table'
  className: 'table table-scriped table-hover selectable-table'
  childView: Miner.Views.JobResultView
  childViewContainer: 'tbody'
  template: HandlebarsTemplates['job_results']

