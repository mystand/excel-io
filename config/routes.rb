ExcelIO::Engine.routes.draw do
  puts "+++++++++++++++++"
  puts "+++++++++++++++++"
  puts "+++++++++++++++++"
  puts "+++++++++++++++++"
  puts "+++++++++++++++++"

  namespace :excel_i_o do
    get 'excel/export' => "excel_i_o#export_form"
    get 'excel/import' => "excel_i_o#import_form"
    post 'excel/export' => "excel_i_o#export"
    post 'excel/preview_import' => "excel_i_o#preview_import"
    post 'excel/import' => "excel_i_o#import"
    post 'excel/template' => "excel_i_o#template"
  end
end