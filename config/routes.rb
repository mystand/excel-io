ExcelIO::Engine.routes.draw do
  get '/export' => "excel#export_form"
  get '/import' => "excel#import_form"
  post '/export' => "excel#export"
  post '/preview_import' => "excel#preview_import"
  post '/import' => "excel#import"
  post '/template' => "excel#template"
end