window.ExcelMapperExportRule = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getInitialState: ->
    @props.rule

  handleChange: (field, event) ->
    obj = {}
    obj[field] = event.target.value
    @setState obj
    @props.onChange obj

  componentWillReceiveProps: (nextProps) ->
    @setState nextProps.rule

  render: ->
    <td className="export-rule">
      <select name="rules[][field_name]" value={@state.fieldName} onChange={_.partial(@handleChange, "fieldName")}>
        {for nm in @props.fieldNames
           <option value={nm}>{nm}</option>
        }
      </select>
      <input type="hidden" name="rules[][number]"  value={@state.number} onChange={_.partial(@handleChange, "number")}/>
      <input type="hidden" name="rules[][type]" value={@state.type} onChange={_.partial(@handleChange, "type")}/>
      <input name="rules[][custom]" type="hidden" value={@state.custom} onChange= {_.partial(@handleChange, "custom")}/>
      <a className="btn btn-danger btn-sm" onClick={@props.removeRule}>Удалить</a>
    </td>