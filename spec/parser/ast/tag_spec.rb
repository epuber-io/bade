# frozen_string_literal: true

require_relative '../../helper'


describe Bade::Parser do
  include ASTHelper

  context 'tag parsing' do
    it 'parses minimalistic tag' do
      source = 'tag_name'

      ast = n(:root,
              tag('tag_name'))

      assert_ast(ast, source)
    end

    it 'parses minimalistic tag with one attribute' do
      source = 'tag_bla(attr_bla: "abc")'

      ast = n(:root,
              tag('tag_bla',
                  n(:tag_attr, name: 'attr_bla', value: '"abc"')))

      assert_ast(ast, source)
    end

    it 'parses minimalistic tag with multiple attributes' do
      source = <<-BADE.strip_heredoc.rstrip
        tag_bla(a1: "a1", a2: "a2", a3: "a3", a4: "a4", a5: "a5", a6: "a6", a7: "a7", a8: "a8", a9: "a9", a10: "a10")
      BADE

      ast = n(:root,
              tag('tag_bla',
                  n(:tag_attr, name: 'a1', value: '"a1"'),
                  n(:tag_attr, name: 'a2', value: '"a2"'),
                  n(:tag_attr, name: 'a3', value: '"a3"'),
                  n(:tag_attr, name: 'a4', value: '"a4"'),
                  n(:tag_attr, name: 'a5', value: '"a5"'),
                  n(:tag_attr, name: 'a6', value: '"a6"'),
                  n(:tag_attr, name: 'a7', value: '"a7"'),
                  n(:tag_attr, name: 'a8', value: '"a8"'),
                  n(:tag_attr, name: 'a9', value: '"a9"'),
                  n(:tag_attr, name: 'a10', value: '"a10"'),
                 ),
             )

      assert_ast(ast, source)
    end


    it 'parses tag with text' do
      source = 'tagX With some text we can use'

      ast = n(:root,
              tag('tagX',
                  text('With some text we can use')))

      assert_ast(ast, source)
    end

    it 'parses tag with text and new line after' do
      source = 'tagX With some text we can use
'

      ast = n(:root,
              tag('tagX',
                  text('With some text we can use')),
              n(:newline))

      assert_ast(ast, source)
    end


    it 'parses nested tags' do
      source = 'tag1
  tag2'

      ast = n(:root,
              tag('tag1',
                  n(:newline),
                  tag('tag2')))

      assert_ast(ast, source)
    end

    it 'parses output right after tag' do
      source = 'tag1= magic_variable.name.baf'
      ast = n(:root,
              tag('tag1',
                  n(:output, value: 'magic_variable.name.baf', escaped: false)))

      assert_ast(ast, source)
    end

    it 'parses output on next line after tag' do
      source = 'tag1
  = magic_variable.name.baf'
      ast = n(:root,
              tag('tag1',
                  n(:newline),
                  n(:output, value: 'magic_variable.name.baf', escaped: false)))

      assert_ast(ast, source)
    end

    context 'conditional output' do
      it 'parses conditional output after tag' do
        source = <<-BADE.strip_heredoc
          tag?= nil_value
          tag?= value
        BADE

        ast = n(:root,
                tag('tag',
                    n(:output, value: 'nil_value', conditional: true)),
                n(:newline),
                tag('tag',
                    n(:output, value: 'value', conditional: true)),
                n(:newline))

        assert_ast(ast, source)
      end

      it 'parses conditional output on next line' do
        source = <<-BADE.strip_heredoc
          tag
            ?= nil_value
          tag
            ?= value
        BADE

        ast = n(:root,
                tag('tag',
                    n(:newline),
                    n(:output, value: 'nil_value', conditional: true)),
                n(:newline),
                tag('tag',
                    n(:newline),
                    n(:output, value: 'value', conditional: true)),
                n(:newline))

        assert_ast(ast, source)
      end
    end


    it 'parses inline tags right after tag' do
      source = 'tag1: tag2 some text'

      ast = n(:root,
              tag('tag1',
                  tag('tag2',
                      text('some text'))))

      assert_ast(ast, source)
    end

    it 'parses nested inline tags' do
      source = 'tag1: tag2 some text
  tag3: tag4 some other text'

      ast = n(:root,
              tag('tag1',
                  tag('tag2',
                      text('some text'),
                      n(:newline),
                      tag('tag3',
                          tag('tag4',
                              text('some other text'))))))

      assert_ast(ast, source)
    end

    it 'parses inline tags right after tag with attributes' do
      source = 'tag1(a1: "baf"): tag2(a2: "abc") some text'

      ast = n(:root,
              tag('tag1',
                  n(:tag_attr, name: 'a1', value: '"baf"'),
                  tag('tag2',
                      n(:tag_attr, name: 'a2', value: '"abc"'),
                      text('some text'))))

      assert_ast(ast, source)
    end
  end
end
