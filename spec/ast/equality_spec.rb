# frozen_string_literal: true

require_relative '../helper'


describe Bade::AST::Node do
  context '#==' do
    it 'equals correctly for same instances' do
      node1 = Bade::AST::Node.new(:random_tag_123)
      expect(node1).to eq node1
    end
    it 'equals correctly for same types' do
      node1 = Bade::AST::Node.new(:random_tag_123)
      node2 = Bade::AST::Node.new(:random_tag_123)
      expect(node1).to eq node2
    end
    it 'not equals correctly for different types' do
      node1 = Bade::AST::Node.new(:random_tag_123)
      node2 = Bade::AST::Node.new(:root)
      expect(node1).to_not eq node2
    end
  end
end

describe Bade::AST::ValueNode do
  context '#==' do
    it 'equals correctly for same instances' do
      node1 = Bade::AST::ValueNode.new(:random_tag_123)
      node1.value = 'abc some text'
      expect(node1).to eq node1
    end
    it 'equals correctly for same objects' do
      node1 = Bade::AST::ValueNode.new(:random_tag_123)
      node1.value = 'abc some text'
      node2 = Bade::AST::ValueNode.new(:random_tag_123)
      node2.value = 'abc some text'
      expect(node1).to eq node2
    end
    it 'not equals correctly for different types' do
      node1 = Bade::AST::ValueNode.new(:random_tag_123)
      node2 = Bade::AST::ValueNode.new(:root)
      expect(node1).to_not eq node2
    end
    it 'not equals correctly for same type with different values' do
      node1 = Bade::AST::ValueNode.new(:random_tag_123)
      node1.value = 'abc'
      node2 = Bade::AST::ValueNode.new(:random_tag_123)
      node2.value = 'xyz'
      expect(node1).to_not eq node2
    end
  end
end

describe Bade::AST::StaticTextNode do
  context '#==' do
    it 'equals correctly for same instances' do
      node1 = Bade::AST::StaticTextNode.new(:random_tag_123)
      node1.value = 'abc some text'
      expect(node1).to eq node1
    end
    it 'equals correctly for same objects' do
      node1 = Bade::AST::StaticTextNode.new(:random_tag_123)
      node1.value = 'abc some text'
      node2 = Bade::AST::StaticTextNode.new(:random_tag_123)
      node2.value = 'abc some text'
      expect(node1).to eq node2
    end
    it 'not equals correctly for different types' do
      node1 = Bade::AST::StaticTextNode.new(:random_tag_123)
      node2 = Bade::AST::StaticTextNode.new(:root)
      expect(node1).to_not eq node2
    end
    it 'not equals correctly for same type with different values' do
      node1 = Bade::AST::StaticTextNode.new(:random_tag_123)
      node1.value = 'abc'
      node2 = Bade::AST::StaticTextNode.new(:random_tag_123)
      node2.value = 'xyz'
      expect(node1).to_not eq node2
    end
  end
end

describe Bade::AST::KeyValueNode do
  context '#==' do
    it 'equals correctly for same instances' do
      node1 = Bade::AST::KeyValueNode.new(:random_tag_123)
      node1.value = 'abc some text'
      expect(node1).to eq node1
    end
    it 'equals correctly for same objects' do
      node1 = Bade::AST::KeyValueNode.new(:random_tag_123)
      node1.name = 'key'
      node1.value = 'abc some text'
      node2 = Bade::AST::KeyValueNode.new(:random_tag_123)
      node2.name = 'key'
      node2.value = 'abc some text'

      expect(node1).to eq node2
    end

    it 'not equals correctly for different types' do
      node1 = Bade::AST::KeyValueNode.new(:random_tag_123)
      node2 = Bade::AST::KeyValueNode.new(:root)

      expect(node1).to_not eq node2
    end
    it 'not equals correctly for same type with different values' do
      node1 = Bade::AST::KeyValueNode.new(:random_tag_123)
      node1.name = 'key'
      node1.value = 'abc'
      node2 = Bade::AST::KeyValueNode.new(:random_tag_123)
      node2.name = 'key'
      node2.value = 'xyz'

      expect(node1).to_not eq node2
    end
    it 'not equals correctly for same type with different names' do
      node1 = Bade::AST::KeyValueNode.new(:random_tag_123)
      node1.name = 'key1'
      node1.value = 'abc'
      node2 = Bade::AST::KeyValueNode.new(:random_tag_123)
      node2.name = 'key2'
      node2.value = 'abc'

      expect(node1).to_not eq node2
    end
  end
end


describe Bade::AST::DoctypeNode do
  context '#==' do
    it 'equals correctly for same instances' do
      node1 = Bade::AST::DoctypeNode.new(:random_tag_123)
      node1.value = 'abc some text'
      expect(node1).to eq node1
    end
    it 'equals correctly for same objects' do
      node1 = Bade::AST::DoctypeNode.new(:random_tag_123)
      node1.value = 'abc some text'
      node2 = Bade::AST::DoctypeNode.new(:random_tag_123)
      node2.value = 'abc some text'
      expect(node1).to eq node2
    end
    it 'not equals correctly for different types' do
      node1 = Bade::AST::DoctypeNode.new(:random_tag_123)
      node2 = Bade::AST::DoctypeNode.new(:root)
      expect(node1).to_not eq node2
    end
    it 'not equals correctly for same type with different values' do
      node1 = Bade::AST::DoctypeNode.new(:random_tag_123)
      node1.value = 'abc'
      node2 = Bade::AST::DoctypeNode.new(:random_tag_123)
      node2.value = 'xyz'
      expect(node1).to_not eq node2
    end
  end
end

describe Bade::AST::MixinCommonNode do
  context '#==' do
    it 'equals correctly for same instances' do
      node1 = Bade::AST::MixinCommonNode.new(:random_tag_123)
      node1.name = 'abc some text'
      expect(node1).to eq node1
    end
    it 'equals correctly for same objects' do
      node1 = Bade::AST::MixinCommonNode.new(:random_tag_123)
      node1.name = 'abc'
      node2 = Bade::AST::MixinCommonNode.new(:random_tag_123)
      node2.name = 'abc'
      expect(node1).to eq node2
    end
    it 'not equals correctly for different types' do
      node1 = Bade::AST::MixinCommonNode.new(:random_tag_123)
      node2 = Bade::AST::MixinCommonNode.new(:root)
      expect(node1).to_not eq node2
    end
    it 'not equals correctly for same type with different names' do
      node1 = Bade::AST::MixinCommonNode.new(:random_tag_123)
      node1.name = 'abc'
      node2 = Bade::AST::MixinCommonNode.new(:random_tag_123)
      node2.name = 'xyz'
      expect(node1).to_not eq node2
    end
  end
end

describe Bade::AST::TagNode do
  context '#==' do
    it 'equals correctly for same instances' do
      node1 = Bade::AST::TagNode.new(:random_tag_123)
      node1.name = 'abc some text'
      expect(node1).to eq node1
    end
    it 'equals correctly for same objects' do
      node1 = Bade::AST::TagNode.new(:random_tag_123)
      node1.name = 'abc'
      node2 = Bade::AST::TagNode.new(:random_tag_123)
      node2.name = 'abc'
      expect(node1).to eq node2
    end
    it 'not equals correctly for different types' do
      node1 = Bade::AST::TagNode.new(:random_tag_123)
      node2 = Bade::AST::TagNode.new(:root)
      expect(node1).to_not eq node2
    end
    it 'not equals correctly for same type with different names' do
      node1 = Bade::AST::TagNode.new(:random_tag_123)
      node1.name = 'abc'
      node2 = Bade::AST::TagNode.new(:random_tag_123)
      node2.name = 'xyz'
      expect(node1).to_not eq node2
    end
  end
end
