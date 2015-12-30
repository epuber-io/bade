# frozen_string_literal: true

class String
  SPACE_CHAR = ' '
  TAB_CHAR = "\t"

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

  def __chars_count_for_indent(indent, tabsize)
    count = 0
    self.each_char do |char|
      break if indent <= 0

      case char
      when SPACE_CHAR
        indent -= 1
      when TAB_CHAR
        if indent - tabsize < 0
          raise StandardError, 'malformed tabs'
        end

        indent -= tabsize
      else
        break
      end

      count += 1
    end

    count
  end

  # Remove indent
  #
  # @param [Int] indent
  # @param [Int] tabsize
  #
  def remove_indent(indent, tabsize)
    remove_first(__chars_count_for_indent(indent, tabsize))
  end


  # Remove indent
  #
  # @param [Int] indent
  # @param [Int] tabsize
  #
  def remove_indent!(indent, tabsize)
    remove_first!(__chars_count_for_indent(indent, tabsize))
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
      if char == SPACE_CHAR
        count += 1
      elsif char == TAB_CHAR
        count += tabsize
      else
        break
      end
    end

    count
  end

end
