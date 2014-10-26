
module Bade
  # Escape input text with html escapes
  #
  # @param [String] text
  #
  # @return [String]
  #
  def html_escaped(text)
    text.sub('&', '&amp;')
        .sub('<', '&lt;')
        .sub('>', '&gt;')
        .sub('"', '&quot;')
  end
end
