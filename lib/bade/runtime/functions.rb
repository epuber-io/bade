module Bade
  def html_escaped(text)
    result = String(text)
      .sub(/&/, '&amp;')
      .sub(/</, '&lt;')
      .sub(/>/, '&gt;')
      .sub(/"/, '&quot;')

    if result == text
      text
    else
      result
    end
  end
end
