  
  
module ProjectTypesHelper

  def toggle_checkboxes_text_link(text,selector)
    link_to_function text,
                     "toggleCheckboxesBySelector('#{selector}')",
                     :title => "#{l(:button_check_all)} / #{l(:button_uncheck_all)}"
  end

end