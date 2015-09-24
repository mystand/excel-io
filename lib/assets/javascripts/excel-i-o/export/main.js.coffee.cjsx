window.ExcelMapperExportMain = React.createClass
  mixins: [React.addons.LinkedStateMixin],
  getInitialState: ->
    template:
      fieldName: "title"
      type: undefined
      custom: false
    fieldsData: JSON.parse(@props.fieldsData)
    fieldNames: JSON.parse(@props.fieldNames)
    sampleData: JSON.parse(@props.sampleData)
    downloadUrl: @props.download
    rules: []
    types: ["text", "string",
            "localized",
            "integer", "float",
            "boolean", "belongs_to",
            "has_many"]

  availableFieldNames: (current = null)->
    selected = _(@state.rules).pluck("fieldName")
    _.filter @state.fieldNames, (obj)->
      obj == current || !(obj in selected)

  downloadExcel: ->
    $.ajax
      data:
        model: @props.model
        rules: @state.rules
      type: "POST"
      url: @props.downloadUrl
      success: (url) =>
        window.location = url
        console.log(arguments)
      error: =>
        console.log(arguments)

  addRule: ->
    newRule = _.clone(@state.template)
    newRule.fieldName = @availableFieldNames()[0]
    rules = @state.rules
    rules.push newRule
    @setRules rules, @scrollToLeft

  scrollToLeft: ->
    node = @getDOMNode()
    table = $ "table", node
    container = $ ".left-block", node
    left = table.width() - container.width()
    container.scrollLeft left

  getType: (name) ->
    @state.fieldsData[name]["type"]

  getCustom: (name) ->
    @state.fieldsData[name]["custom"]

  setRules: (rules, clbck) ->
    result = for rule, i in rules
      rule.number = i + 1
      rule.type = @getType rule.fieldName
      rule.custom = @getCustom rule.fieldName
      rule
    @setState rules: result, clbck

  updateRule: (currentRule, newParams) ->
    index = @state.rules.indexOf currentRule
    rules = @state.rules
    for key, value of newParams
      if key is "number"
        value = parseInt(value)
      rules[index][key] = value
    @setRules rules

  removeRule: (rule) ->
    index = @state.rules.indexOf(rule)
    if index > -1
      rules = []
      for rule, it in @state.rules
        rules.push(rule) if it != index
      @setRules rules

  render: ->
    window.rules = @state.rules
    samples = for obj in @state.sampleData
      tds = for rule in @state.rules
        <td>{obj[rule.fieldName]}</td>
      <tr>{tds}</tr>

    rulesViews = for rule in @state.rules
      <ExcelMapperExportRule rule={rule} types={@state.types}
      fieldNames={@availableFieldNames(rule.fieldName)}
      onChange={_.partial(@updateRule, rule)} removeRule={_.partial(@removeRule, rule)} />

    <div className="excel-mapper-export-container">
    <div className="right-block">
      <a className="btn btn-primary export-btn" onClick={@downloadExcel}>Скачать Excel</a>
    </div>
    <div className="left-block">
    <table className="white-bg table-striped">
      <tr>{rulesViews}<td className="add-rule-container">
          { @availableFieldNames().length > 0 ? <a className="add-rule btn btn-primary btn-sm" onClick={@addRule}>
            <i className="fa fa-plus"></i>Добавить столбец
          </a> : null}
        </td>
      </tr>{samples}
    </table>
    </div>
    </div>