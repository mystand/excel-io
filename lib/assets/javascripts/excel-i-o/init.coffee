#
#$ ->
#  el = $ ".excel-mapper-export-container"
#  if el.length > 0
#    data = el.data("field-names")
#    fieldNames = _(data).keys()
#    sampleData = el.data "examples"
#
#    React.render(
#      React.createElement(
#        window.ExcelMapper.Export.Main, {
#          fieldsData: data,
#          sampleData: sampleData,
#          fieldNames: fieldNames
#        }), el[0])