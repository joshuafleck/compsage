module TextBoxExtension
  def set_without_blur(setThis)
    assert_exists
    assert_enabled
    assert_not_readonly
    
    highlight(:set)
    @o.scrollIntoView
    @o.focus
    @o.select()
    @o.fireEvent("onSelect")
    @o.value = ""
    @o.fireEvent("onKeyPress")
    doKeyPress( setThis )
    highlight(:clear)
  end
end
