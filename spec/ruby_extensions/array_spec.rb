# frozen_string_literal: true

require_relative '../../lib/bade/ruby_extensions/array'

describe Array do
  context '#rindex_last_matching' do
    it 'can find index of last matching item from back' do
      index = %w[abc abc abc a].rindex_last_matching { |item| item.length == 1 }
      expect(index).to eq 3
    end

    it 'can find index of last matching item from back' do
      index = %w[a a a a].rindex_last_matching { |item| item.length == 1 }
      expect(index).to eq 0
    end

    it 'returns nil when last item does not match' do
      index = %w[abc abc abc ab].rindex_last_matching { |item| item.length == 1 }
      expect(index).to be_nil
    end

    it 'return nil for empty array' do
      index = [].rindex_last_matching { |item| item.length == 1 }
      expect(index).to be_nil
    end
  end

  context '#rcount_matching' do
    it 'can find items matching block from back' do
      index = %w[abc abc abc a].rcount_matching { |item| item.length == 1 }
      expect(index).to eq 1
    end

    it 'can find items matching block from back' do
      index = %w[a a a a].rcount_matching { |item| item.length == 1 }
      expect(index).to eq 4
    end

    it 'returns 0 when no match' do
      index = %w[abc abc abc ab].rcount_matching { |item| item.length == 1 }
      expect(index).to eq 0
    end

    it 'return 0 for empty array' do
      index = [].rcount_matching { |item| item.length == 1 }
      expect(index).to eq 0
    end
  end
end
