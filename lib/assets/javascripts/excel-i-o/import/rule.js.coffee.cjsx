window.ExcelMapperImportRule = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getInitialState: ->
    @props.rule

  handleChange: (field, event) ->
    state = {}
    state[field] = event.target.value
    @setState state, =>
      @props.onChange @state.number - 1, @state

  componentWillReceiveProps: (nextProps) ->
    @setState nextProps.rule

  addRule: ->   
    if @state.fieldName
      fieldName = @state.fieldName
    else
      fieldName = @props.fieldNames(@state.fieldName)[0]

    state = 
      enabled: yes
      fieldName: fieldName

    @setState state,  =>
      @props.onChange @state.number - 1, @state
  
  removeRule: ->
    @setState enabled: no, =>
      @props.onChange @state.number - 1, @state

  render: ->
    if @state.enabled
    
      <td className="import-rule">
        <select name="rules[][field_name]" value={@state.fieldName} onChange={_.partial(@handleChange, "fieldName")}>
          {for nm in @props.fieldNames(@state.fieldName)
             <option value={nm}>{nm}</option>
          }
        </select>
        <input type="hidden" name="rules[][number]"  value={@state.number} onChange={_.partial(@handleChange, "number")}/>
        <input type="hidden" name="rules[][type]" value={@state.type} onChange={_.partial(@handleChange, "type")}/>
        <input name="rules[][custom]" type="hidden" value={@state.custom} onChange= {_.partial(@handleChange, "custom")}/>
        <a className="btn btn-danger btn-sm" onClick={@removeRule}>Удалить</a>
      </td>

    else

      <td className="add-rule-container">
        <a className="add-rule btn btn-primary btn-sm" onClick={@addRule}>
          <i className="fa fa-plus"></i> Добавить
        </a>
      </td>