# frozen_string_literal: true

require_relative '../../helper'


describe Bade::Parser do
  include ASTHelper

  context 'mixing all things together' do
    it 'parse nested mixin call, code and tag' do
      source = <<-SOURCE.strip_heredoc
        +abc
          - if abc.empty?
            | empty
          - else
            items
              = abc.join()
          - end
      SOURCE

      ast = n(:root,
              n(:mixin_call, {name: 'abc'},
                n(:newline),
                n(:code, value: 'if abc.empty?'),
                n(:newline),
                n(:text, value: 'empty'),
                n(:newline),
                n(:code, value: 'else'),
                n(:newline),
                tag('items',
                    n(:newline),
                    n(:output, value: 'abc.join()')
                ),
                n(:newline),
                n(:code, value: 'end')),
              n(:newline)
      )

      assert_ast(ast, source)
    end
  end
end
