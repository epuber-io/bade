# frozen_string_literal: true

require 'bade/ast/string_serializer'

require_relative '../helper'


describe Bade::AST::StringSerializer do
  include ASTHelper

  it 'can serialize simple tag' do
    tag = tag('tag_name')

    sut = Bade::AST::StringSerializer.new(tag)

    expect(sut.to_s).to eq '(:tag tag_name)'
  end

  it 'can serialize tag with attributes' do
    tag = tag('tag_name',
              n(:tag_attr, name: 'attr-name', value: '"attr-value"'))
    sut = Bade::AST::StringSerializer.new(tag)

    expected = '(:tag tag_name
  (:tag_attr attr-name:"attr-value")
)'

    expect(sut.to_s).to eq expected
  end

  it 'can serialize nested tags with attributes and text' do
    root = tag('tag_name',
               n(:tag_attr, name: 'attr', value: 'value'),
               tag('tag_2',
                   n(:tag_attr, name: 'attr2', value: 'value2'),
                   n(:static_text, value: 'baf')))
    sut = Bade::AST::StringSerializer.new(root)

    expected = <<-AST.strip_heredoc.rstrip
      (:tag tag_name
        (:tag_attr attr:value)
        (:tag tag_2
          (:tag_attr attr2:value2)
          (:static_text baf)
        )
      )
    AST

    expect(sut.to_s).to eq expected
  end

  it 'can serialize simple mixin' do
    root = n(:mixin_decl, { name: 'blaf' },
             n(:mixin_param, value: 'abc'))

    sut = Bade::AST::StringSerializer.new(root)

    expected = '(:mixin_decl blaf
  (:mixin_param abc)
)'

    expect(sut.to_s).to eq expected
  end
end
