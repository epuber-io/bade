
require_relative '../../helper'

include ASTHelper

describe Bade::Parser do
  context 'tag parsing' do
    it 'parses minimalistic tag' do
      source = 'tag_name'

      root = n(:root,
               n(:tag, name: 'tag_name'))

      assert_nodes(root, source)
    end
  end
end
