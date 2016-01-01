# frozen_string_literal: true

class Array
  # Returns index of last matching item when iterating from back to start of +self+.
  #
  # Returns nil when the first item does not match (when iterating from back).
  #
  # @return [Fixnum]
  #
  def rindex_last_matching(&block)
    return nil if empty?

    index = nil

    current_index = count - 1
    reverse_each do |item|
      if block.call(item)
        index = current_index
        current_index -= 1
      else
        break
      end
    end

    index
  end

  # Returns count of items that matches, iteration starts at the end and stops on first not matching item.
  #
  # @return [Fixnum] count of items
  #
  def rcount_matching(&block)
    count = 0

    reverse_each do |item|
      if block.call(item)
        count += 1
      else
        break
      end
    end

    count
  end
end
