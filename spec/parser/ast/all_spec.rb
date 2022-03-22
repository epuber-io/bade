# frozen_string_literal: true

require_relative '../../helper'


describe Bade::Parser do
  include ASTHelper

  context 'mixing all things together' do
    it 'parse nested mixin call, code and tag' do
      source = <<~BADE
        +abc
          - if abc.empty?
            | empty
          - else
            items
              = abc.join()
          - end
      BADE

      ast = n(:root,
              n(:mixin_call, { name: 'abc' },
                n(:newline),
                code('if abc.empty?'),
                n(:newline),
                n(:static_text, value: 'empty'),
                n(:newline),
                code('else'),
                n(:newline),
                tag('items',
                    n(:newline),
                    n(:output, value: 'abc.join()')),
                n(:newline),
                code('end')),
              n(:newline))

      assert_ast(ast, source)
    end
  end
end
