# frozen_string_literal: true

class String

  # Creates new string surrounded by single quotes
  #
  # @return [String]
  #
  def single_quote
    %('#{self}')
  end


  def blank?
    strip.length == 0
  end


  def remove_last(count = 1)
    slice(0, length - count)
  end

  def remove_last!(count = 1)
    slice!(length - count, count)
  end


  def remove_first(count = 1)
    slice(count, length - count)
  end

  def remove_first!(count = 1)
    slice!(0, count)
  end


  # Remove indent
  #
  # @param [Int] indent
  # @param [Int] tabsize
  #
  def remove_indent(indent, tabsize)
    self.dup.remove_indent!(indent, tabsize)
  end


  # Remove indent
  #
  # @param [Int] indent
  # @param [Int] tabsize
  #
  def remove_indent!(indent, tabsize)
    count = 0
    self.each_char do |char|

      if indent <= 0
        break
      elsif char == ' '
        indent -= 1
      elsif char == "\t"
        if indent - tabsize < 0
          raise StandardError, 'malformed tabs'
        end

        indent -= tabsize
      else
        break
      end

      count += 1
    end

    self[0 ... self.length] = self[count ... self.length]
  end


  # Calculate indent for line
  #
  # @param [Int] tabsize
  #
  # @return [Int] indent size
  #
  def get_indent(tabsize)
    count = 0

    self.each_char do |char|
      if char == ' '
        count += 1
      elsif char == "\t"
        count += tabsize
      else
        break
      end
    end

    count
  end

end
