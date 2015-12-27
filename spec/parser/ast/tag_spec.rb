
require_relative '../../helper'

include ASTHelper

describe Bade::Parser do
  context 'tag parsing' do
    it 'parses minimalistic tag' do
      source = 'tag_name'

      ast = n(:root,
              n(:tag, {name: 'tag_name'}))

      assert_ast(ast, source)
    end

    it 'parses minimalistic tag with one attribute' do
      source = 'tag_bla(attr_bla: "abc")'

      ast = n(:root,
              n(:tag, {name: 'tag_bla'},
                n(:tag_attribute, {name: 'attr_bla', value: '"abc"'})))

      assert_ast(ast, source)
    end

    it 'parses minimalistic tag with multiple attributes' do
      source = 'tag_bla(a1: "a1", a2: "a2", a3: "a3", a4: "a4", a5: "a5", a6: "a6", a7: "a7", a8: "a8", a9: "a9", a10: "a10")'

      ast = n(:root,
              n(:tag, {name: 'tag_bla'},
                n(:tag_attribute, {name: 'a1', value: '"a1"'}),
                n(:tag_attribute, {name: 'a2', value: '"a2"'}),
                n(:tag_attribute, {name: 'a3', value: '"a3"'}),
                n(:tag_attribute, {name: 'a4', value: '"a4"'}),
                n(:tag_attribute, {name: 'a5', value: '"a5"'}),
                n(:tag_attribute, {name: 'a6', value: '"a6"'}),
                n(:tag_attribute, {name: 'a7', value: '"a7"'}),
                n(:tag_attribute, {name: 'a8', value: '"a8"'}),
                n(:tag_attribute, {name: 'a9', value: '"a9"'}),
                n(:tag_attribute, {name: 'a10', value: '"a10"'}),
              ))

      assert_ast(ast, source)
    end


    it 'parses tag with text' do
      source = 'tagX With some text we can use'

      ast = n(:root,
              n(:tag, {name: 'tagX'},
                n(:text, {value: 'With some text we can use'})))

      assert_ast(ast, source)
    end

    it 'parses tag with text and new line after' do
      source = 'tagX With some text we can use
'

      ast = n(:root,
              n(:tag, {name: 'tagX'},
                n(:text, {value: 'With some text we can use'}),
                n(:newline)))

      assert_ast(ast, source)
    end


    it 'parses nested tags' do
      source = 'tag1
  tag2'

      ast = n(:root,
              n(:tag, {name: 'tag1'},
                n(:newline),
                n(:tag, {name: 'tag2'})))

      assert_ast(ast, source)
    end
  end
end
