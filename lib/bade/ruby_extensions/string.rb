# frozen_string_literal: true

# :nodoc:
class String
  SPACE_CHAR = ' '.freeze
  TAB_CHAR = "\t".freeze

  # Creates new string surrounded by single quotes
  #
  # @return [String]
  #
  def single_quote
    %('#{self}')
  end

  def blank?
    strip.empty?
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
    each_char do |char|
      break if indent <= 0

      case char
      when SPACE_CHAR
        indent -= 1
      when TAB_CHAR
        raise StandardError, 'malformed tabs' if indent - tabsize < 0

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

    each_char do |char|
      case char
      when SPACE_CHAR
        count += 1
      when TAB_CHAR
        count += tabsize
      else
        break
      end
    end

    count
  end

  # source: http://apidock.com/rails/String/strip_heredoc
  # @return [String]
  #
  def strip_heredoc
    min_val = scan(/^[ \t]*(?=\S)/).min
    indent = min_val&.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end
