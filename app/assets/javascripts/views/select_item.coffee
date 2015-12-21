class Miner.Views.SelectItemView extends Marionette.ItemView
  tagName: 'option'
  template: HandlebarsTemplates['select_item']

  initialize: ->
    @el.value = @model.get('id')

class Miner.Views.SelectItemsView extends Marionette.CollectionView
  childView: Miner.Views.SelectItemView
  tagName: 'select'
  className: 'form-control'
