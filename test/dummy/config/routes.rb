Rails.application.routes.draw do

  mount ExcelIO::Engine => "/excel_i_o"
end
