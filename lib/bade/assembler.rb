# frozen_string_literal: true


module Bade
  require_relative 'assembly_instruction'

  class Assembler
    BUFF_NAME = :__buff
    MIXINS_NAME = :__mixins
    NEW_LINE_NAME = :__new_line
    CURRENT_INDENT_NAME = :__indent
    BASE_INDENT_NAME = :__base_indent

    DEFAULT_BLOCK_NAME = 'default_block'.freeze

    # @param [Bade::AST::Node || Bade::AST::Document] root_node
    #
    def initialize(root_node)
      if root_node.is_a?(AST::Document)
        @document = root_node
        @root_node = @document.root
      else
        @document = nil
        @root_node = root_node
      end
    end

    # @return [Array<Bade::AssemblyInstruction>]
    #
    def assembly
      @instructions = []
      @code_indent = 0

      visit_nodes(@root_node.children)

      @instructions
    end

    # Method for indenting generated code, indent is raised only in passed block
    #
    # @return [nil]
    #
    def code_indent(plus = 1)
      @code_indent += plus
      yield
      @code_indent -= plus
    end

    # @param [Array<Bade::AST::Node>]
    #
    def visit_nodes(nodes)
      nodes.each do |node|
        case node.type
        when :static_text
          add_text(node.value)

        when :output
          data = node.value
          output_code = if node.escaped
                          "__html_escaped(#{data})"
                        else
                          "#{data}"
                        end

          @instructions << AssemblyInstruction.new(:dynamic_value, output_code)

        when :doctype
          add_text(node.xml_output)

        when :comment
          comment_text = '#' + node.children.map(&:value).join("\n#")
          add_code(comment_text)

        when :html_comment
          add_text('<!-- ')
          visit_nodes(node.children)
          add_text(' -->')

        when :tag
          visit_tag(node)

        when :code
          add_code(node.value)

        when :import
          next if @document.nil?
          next if @document.file_path.nil?

          base_path = File.expand_path(node.value, File.dirname(@document.file_path))
          load_path = if base_path.end_with?('.rb') && File.exist?(base_path)
                        base_path
                      elsif File.exist?("#{base_path}.rb")
                        "#{base_path}.rb"
                      end

          unless load_path.nil?
            code = "load('#{load_path}')"
            add_code(code)
          end

        when :mixin_decl
          visit_block_decl(node)

        when :mixin_call
          params = formatted_mixin_params(node)
          code = "#{MIXINS_NAME}['#{node.name}'].call!(#{params})"
          add_code(code)

        when :newline
          # do nothing

        else
          raise "Unknown type #{node.type}"

        end
      end
    end

    # @param [Bade::AST::TagNode] node
    #
    def visit_tag(node)
      children_wo_attributes = (node.children - node.attributes)

      other_than_new_lines = children_wo_attributes.any? { |n| n.type != :newline }

      conditional_nodes = node.children.select { |n| n.type == :output && n.conditional }

      unless conditional_nodes.empty?
        add_code("if (#{conditional_nodes.map(&:value).join(') && (')})")

        @code_indent += 1
      end

      add_text("<#{node.name}")
      @instructions += formatted_attributes(node)

      end_of_start_tag = if other_than_new_lines
                           '>'
                         else
                           '/>'
                         end
      add_text(end_of_start_tag)

      if other_than_new_lines
        last_node = children_wo_attributes.last
        is_last_newline = !last_node.nil? && last_node.type == :newline
        nodes = if is_last_newline
                  children_wo_attributes[0...-1]
                else
                  children_wo_attributes
                end

        code_indent do
          visit_nodes(nodes)
        end

        add_text("</#{node.name}>")

        # print new line after the tag
        visit_nodes([last_node]) if is_last_newline
      end

      unless conditional_nodes.empty? # rubocop:disable Style/GuardClause
        @code_indent -= 1

        add_code('end')
      end
    end

    # @param [Bade::AST::TagNode] tag_node
    #
    # @return [Array<Bade::AssemblyInstruction>] formatted attributes
    #
    def formatted_attributes(tag_node)
      all_attributes = Hash.new { |hash, key| hash[key] = [] }

      tag_node.attributes.each do |attr|
        all_attributes[attr.name] << attr.value
      end

      instructions = []
      all_attributes.each do |attr_name, values|
        joined = values.join('), (')
        code = "__tag_render_attribute('#{attr_name}', (#{joined}))"
        instructions << AssemblyInstruction.new(:dynamic_value, code)
      end

      instructions
    end

    # @param [Bade::AST::MixinCommonNode] mixin_node
    #
    # @return [String] formatted params
    #
    def formatted_mixin_params(mixin_node)
      params = mixin_node.params
      result = []

      if mixin_node.type == :mixin_call
        blocks = mixin_node.blocks

        other_children = (mixin_node.children - mixin_node.blocks - mixin_node.params)
        if other_children.count { |n| n.type != :newline } > 0
          def_block_node = AST::NodeRegistrator.create(:mixin_block, mixin_node.lineno)
          def_block_node.name = DEFAULT_BLOCK_NAME
          def_block_node.children = other_children

          blocks << def_block_node
        end

        if !blocks.empty?
          add_code '__blocks = {}'

          blocks.each do |block|
            block_definition(block)
          end

          result << '__blocks.dup'
        else
          result << '{}'
        end
      elsif mixin_node.type == :mixin_decl
        result << '__blocks'
      end


      # normal params
      result += params.select { |n| n.type == :mixin_param }.map(&:value)
      result += params.select { |n| n.type == :mixin_key_param }.map { |param| "#{param.name}: #{param.value}" }

      result.join(', ')
    end


    # Generates code for definition of block
    #
    # @param [MixinCallBlockNode] block_node
    #
    # @return [nil]
    #
    def block_definition(block_node)
      add_code "__blocks['#{block_node.name}'] = __create_block('#{block_node.name}') do"

      code_indent do
        add_code '__buffs_push()'

        visit_nodes(block_node.children)

        add_code '__buffs_pop()'
      end

      add_code 'end'
    end

    # Generates code for block variables declaration in mixin definition
    #
    # @param [String] block_name
    #
    # @return [nil]
    #
    def block_name_declaration(block_name)
      add_code "#{block_name} = __blocks.delete('#{block_name}') { __create_block('#{block_name}') }"
    end

    # @param [MixinDeclarationNode] mixin_node
    #
    # @return [nil]
    #
    def blocks_name_declaration(mixin_node)
      block_name_declaration(DEFAULT_BLOCK_NAME)

      mixin_node.params.select { |n| n.type == :mixin_block_param }.each do |param|
        block_name_declaration(param.value)
      end
    end

    # @param [MixinDeclarationNode] current_node
    #
    # @return [nil]
    #
    def visit_block_decl(current_node)
      params = formatted_mixin_params(current_node)
      add_code "#{MIXINS_NAME}['#{current_node.name}'] = __create_mixin('#{current_node.name}', &lambda { |#{params}|"

      code_indent do
        blocks_name_declaration(current_node)
        visit_nodes(current_node.children - current_node.params)
      end

      add_code '})'
    end



    private

    def add_code(text)
      add_inst(AssemblyInstruction.new(:code, text))
    end

    def add_text(text)
      add_inst(AssemblyInstruction.new(:static_text, text))
    end

    def add_inst(inst)
      @instructions << inst
    end
  end
end
