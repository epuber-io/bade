# frozen_string_literal: true

require_relative '../../helper'


describe Bade::Parser do
  include ASTHelper

  context 'mixin declaration parsing' do
    it 'can parse empty mixin declaration' do
      source = 'mixin abc'

      ast = n(:root,
              n(:mixin_decl, {name: 'abc'}))

      assert_ast(ast, source)
    end

    it 'can parse empty mixin declaration with parameters' do
      source = 'mixin abc(a, b, key1: "a", &block_param)'
      ast = n(:root,
              n(:mixin_decl, {name: 'abc'},
                n(:mixin_param, {value: 'a'}),
                n(:mixin_param, {value: 'b'}),
                n(:mixin_key_param, {name: 'key1', value: '"a"'}),
                n(:mixin_block_param, {value: 'block_param'})))

      assert_ast(ast, source)
    end

    it 'can parse mixin declaration with implementation' do
      source = <<-SOURCE.strip_heredoc
        mixin abc
          | text
      SOURCE

      ast = n(:root,
              n(:mixin_decl, {name: 'abc'},
                n(:newline),
                n(:text, {value: 'text'})),
              n(:newline))

      assert_ast(ast, source)
    end

    it 'can parse mixin declaration with attributes and implementation' do
      source = <<-SOURCE.strip_heredoc
        mixin abc(a, b, key1: "a", &block_param)
          | text
      SOURCE

      ast = n(:root,
              n(:mixin_decl, {name: 'abc'},
                n(:mixin_param, {value: 'a'}),
                n(:mixin_param, {value: 'b'}),
                n(:mixin_key_param, {name: 'key1', value: '"a"'}),
                n(:mixin_block_param, {value: 'block_param'}),
                n(:newline),
                n(:text, {value: 'text'})),
              n(:newline))

      assert_ast(ast, source)
    end

    it 'can parse mixin declaration with implementation with multiple blocks' do
      source = <<-SOURCE.strip_heredoc
        mixin abc(&first, &second)
          - first.call
          - second.call!
      SOURCE

      ast = n(:root,
              n(:mixin_decl, {name: 'abc'},
                n(:mixin_block_param, {value: 'first'}),
                n(:mixin_block_param, {value: 'second'}),
                n(:newline),
                n(:code, {value: 'first.call'}),
                n(:newline),
                n(:code, {value: 'second.call!'})),
              n(:newline))

      assert_ast(ast, source)
    end
  end

  context 'mixin calling parsing' do
    it 'can parse empty calling' do
      source = <<-SOURCE.strip_heredoc
        +abc
        +abc()
      SOURCE

      ast = n(:root,
              n(:mixin_call, {name: 'abc'}),
              n(:newline),
              n(:mixin_call, {name: 'abc'}),
              n(:newline))

      assert_ast(ast, source)
    end
    it 'can parse empty calling with default block' do
      source = <<-SOURCE.strip_heredoc
        +abc some text
        +abc() some text
        +abc()
          | some text
      SOURCE

      ast = n(:root,
              n(:mixin_call, {name: 'abc'},
                n(:text, {value: 'some text'})),
              n(:newline),
              n(:mixin_call, {name: 'abc'},
                n(:text, {value: 'some text'})),
              n(:newline),
              n(:mixin_call, {name: 'abc'},
                n(:newline),
                n(:text, {value: 'some text'})),
              n(:newline))

      assert_ast(ast, source)
    end

    it 'can parse calling with parameters' do
      source = <<-SOURCE.strip_heredoc
        +abc('abc') text
        +abc(key1: 'key1') text
        +abc('abc', key1: 'key1') text
        +abc('abc', key1: 'key1')
          block first
            | text
      SOURCE

      ast = n(:root,
              # first line
              n(:mixin_call, {name: 'abc'},
                n(:mixin_param, {value: "'abc'"}),
                n(:text, {value: 'text'})),
              n(:newline),

              # second line
              n(:mixin_call, {name: 'abc'},
                n(:mixin_key_param, {name: 'key1', value: "'key1'"}),
                n(:text, {value: 'text'})),
              n(:newline),

              # third line
              n(:mixin_call, {name: 'abc'},
                n(:mixin_param, {value: "'abc'"}),
                n(:mixin_key_param, {name: 'key1', value: "'key1'"}),
                n(:text, {value: 'text'})),
              n(:newline),

              # rest (lines 4, 5 and 6)
              n(:mixin_call, {name: 'abc'},
                n(:mixin_param, {value: "'abc'"}),
                n(:mixin_key_param, {name: 'key1', value: "'key1'"}),
                n(:newline),
                n(:mixin_block, {name: 'first'},
                  n(:newline),
                  n(:text, {value: 'text'}))),
              n(:newline),
      )

      assert_ast(ast, source)
    end
    it 'can parse calling with parameters and blocks' do
      source = <<-SOURCE.strip_heredoc
        +abc
          block first
            | text
          block second
            | text2
          | text in default block
      SOURCE

      ast = n(:root,
              n(:mixin_call, {name: 'abc'},
                n(:newline),
                n(:mixin_block, {name: 'first'},
                  n(:newline),
                  n(:text, {value: 'text'})),
                n(:newline),
                n(:mixin_block, {name: 'second'},
                  n(:newline),
                  n(:text, {value: 'text2'})),
                n(:newline),
                n(:text, {value: 'text in default block'}),
              ),
              n(:newline),
      )
      assert_ast(ast, source)
    end

    it 'can parse calling with inline' do
      source = <<-SOURCE.strip_heredoc
        +abc: tag2 text
        +abc(param, key2: key2): tag2 text
      SOURCE

      ast = n(:root,
              n(:mixin_call, {name: 'abc'},
                tag('tag2',
                  n(:text, {value: 'text'}))),
              n(:newline),
              n(:mixin_call, {name: 'abc'},
                n(:mixin_param, {value: 'param'}),
                n(:mixin_key_param, {name: 'key2', value: 'key2'}),
                tag('tag2',
                  n(:text, {value: 'text'}))),
              n(:newline),
      )

      assert_ast(ast, source)
    end
  end
end
