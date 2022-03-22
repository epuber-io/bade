# frozen_string_literal: true

require_relative '../../helper'

describe Bade::Parser do
  include ASTHelper

  context 'static text detection' do
    it 'detects normal text' do
      source = <<~BADE
        | abc
      BADE

      ast = n(:root,
              n(:static_text, value: 'abc'),
              newline)

      assert_ast ast, source
    end

    it 'detects normal text with escaped interpolation syntax' do
      source = '| Here is some text & other text. For example Mumford \#{ and sons.'

      ast = n(:root,
              n(:static_text, value: 'Here is some text & other text. For example Mumford #{ and sons.'))

      assert_ast ast, source
    end

    it 'detects text containing interpolation syntax' do
      source = <<~BADE
        | abc \#{abc}
        | Here is some text & other text. For example Mumford \#{'&'} and sons.
        | Here is some text & other text. For example Mumford &{'&'} and sons.
      BADE

      ast = n(:root,
              n(:static_text, value: 'abc '),
              n(:output, value: 'abc'),
              newline,
              n(:static_text, value: 'Here is some text & other text. For example Mumford '),
              n(:output, value: "'&'"),
              n(:static_text, value: ' and sons.'),
              newline,
              n(:static_text, value: 'Here is some text & other text. For example Mumford '),
              n(:output, value: "'&'", escaped: true),
              n(:static_text, value: ' and sons.'),
              newline)

      assert_ast ast, source
    end

    it 'detects text with @' do
      source = '| Here is some text @bla and @ ha.'

      ast = n(:root,
              n(:static_text, value: 'Here is some text @bla and @ ha.'))

      assert_ast ast, source
    end
  end
end
