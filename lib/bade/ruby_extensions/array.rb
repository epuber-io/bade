# frozen_string_literal: true

class Array
  # Returns index of last matching item when iterating from back to start of +self+.
  #
  # Returns nil when the first item does not match (when iterating from back).
  #
  # @return [Fixnum]
  #
  def rindex_last_matching
    return nil if empty?

    index = nil

    current_index = count - 1
    reverse_each do |item|
      break unless yield item

      index = current_index
      current_index -= 1
    end

    index
  end

  # Returns count of items that matches, iteration starts at the end and stops on first not matching item.
  #
  # @return [Fixnum] count of items
  #
  def rcount_matching
    count = 0

    reverse_each do |item|
      break unless yield item

      count += 1
    end

    count
  end
end
