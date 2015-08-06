window.ExcelMapperImportMain = React.createClass
  mixins: [React.addons.LinkedStateMixin],
  getInitialState: ->
    fieldsData: JSON.parse(@props.fieldsData)
    fieldNames: JSON.parse(@props.fieldNames)
    rules: []
    types: ["text", "string",
            "localized",
            "integer", "float",
            "boolean", "belongs_to",
            "has_many"]

  availableFieldNames: (current = null)->
    rules = _(@state.rules).filter (obj) ->
      obj.enabled
    selected = _(rules).pluck("fieldName")

    _.filter @state.fieldNames, (obj)->
      obj == current || !(obj in selected)

  previewExcel: (e) ->
    formData = new FormData()
    formData.append 'file', @file
    $.ajax
      data: formData
      type: "POST"
      url: @props.preview
      processData: false
      contentType: false
      success: @handlePreview
      error: =>
        console.log(arguments)
    false

  importExcel: (e) ->
    formData = new FormData()
    formData.append 'file', @file

    enabledRules = _(@state.rules).where enabled: yes
    rules = _(enabledRules).map (obj) =>
      _.extend _(obj).omit('enabled'), @state.fieldsData[obj.fieldName]

    formData.append 'rules', JSON.stringify(rules)

    $.ajax
      data: formData
      type: "POST"
      url: @props.import
      processData: false
      contentType: false
      success: =>
        console.log(arguments)
        @setState
          uploaded: yes
          preview: no
      error: (body) =>
        console.log(arguments)
        @setState
          errorMessage: body

    false

  handlePreview: (preview) ->
    @setState
      preview:
        data: preview
        height: preview.length
        width: preview[0].length
      rules: 
        ({enabled: no, number: num} for num in [1..preview[0].length])

  handleFile: (e) ->
    @file = e.target.files[0]

  updateRule: (index, rule) ->
    rules = @state.rules

    # _(rules).each (obj) ->
    #   obj.fieldName = undefined if obj.fieldName == rule.fieldName

    rules[index] = rule

    @setState rules: rules

  render: ->  

    window.s = @

    if @state.preview

      preview = for obj in @state.preview.data
        tds = for cell in obj
          <td>{cell}</td>
        <tr>{tds}</tr>

      rulesViews = for num in [0..@state.preview.width - 1]
        <ExcelMapperImportRule types={@state.types} rule={@state.rules[num]}
          fieldNames={@availableFieldNames} onChange={@updateRule}/>

      <div className="excel-mapper-import-container">
        <form method="post" encType="multipart/form-data" 
              action={@props.import} onSubmit={@importExcel} valueLink={@linkState('filePath')}>

          <div className="left-block">
          <table className="white-bg table-striped table">
            <tr>{rulesViews}
            </tr>{preview}
          </table>
          </div>

          <button className="btn btn-primary">Import excel</button>
        </form>

        <div>
          {@state.errorMessage}
        </div>
      </div>

    else

      if @state.uploaded

        <div>
          Загружено!
        </div>

      else 

        <div className="excel-mapper-import-container">
          <form method="post" encType="multipart/form-data" 
                action={@props.preview} onSubmit={@previewExcel} valueLink={@linkState('filePath')}>
            <input name="file" type="file" onChange={@handleFile}></input>
            <button className="btn btn-primary">Upload Excel</button>

          </form>
        </div>