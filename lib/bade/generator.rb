# frozen_string_literal: true

require_relative 'runtime'

require_relative 'ast/document'

module Bade
  class Generator
    BUFF_NAME = :__buff
    MIXINS_NAME = :__mixins
    NEW_LINE_NAME = :__new_line
    CURRENT_INDENT_NAME = :__indent
    BASE_INDENT_NAME = :__base_indent

    DEFAULT_BLOCK_NAME = 'default_block'.freeze

    REQUIRE_RELATIVE_REGEX = /require_relative\s+(['"])(.+)['"]/.freeze

    # @param [Document] document
    #
    # @return [String]
    #
    def self.document_to_lambda_string(document, optimize: false)
      generator = new
      generator.generate_lambda_string(document, optimize: optimize)
    end

    # @param [Bade::AST::Document] document
    #
    # @return [String] string to parse with Ruby
    #
    def generate_lambda_string(document, optimize: false)
      @documents = []
      @buff = []
      @indent = 0
      @code_indent = 0
      @optimize = optimize

      buff_code '# frozen_string_literal: true' # so it can be faster on Ruby 2.3+
      buff_code ''
      buff_code "lambda do |#{NEW_LINE_NAME}: \"\\n\", #{BASE_INDENT_NAME}: '  '|"

      code_indent do
        buff_code "self.#{NEW_LINE_NAME} = #{NEW_LINE_NAME}"
        buff_code "self.#{BASE_INDENT_NAME} = #{BASE_INDENT_NAME}"
        buff_code "__buffs_push(#{location(filename: document.file_path, lineno: 0, label: '<top>')})"

        visit_document(document)

        buff_code "output = #{BUFF_NAME}.join"
        buff_code 'self.__reset'
        buff_code 'output'
      end

      buff_code 'end'

      @buff.join("\n")
    end

    # @param [String] text
    #
    def buff_print_text(text, indent: false, new_line: false) # rubocop:disable Lint/UnusedMethodArgument
      buff_print_value("%Q{#{text}}") unless text.empty?
    end

    # @param [String] text
    #
    def buff_print_static_text(text)
      buff_print_value("'#{text.gsub("'", "\\\\'")}'") unless text.empty?
    end

    def buff_print_value(value)
      # buff_code %Q{#{BUFF_NAME} << #{CURRENT_INDENT_NAME}} if indent
      buff_code("#{BUFF_NAME} << #{value}")
    end

    def buff_code(text)
      text = _fix_required_relative(text)

      @buff << "#{'  ' * @code_indent}#{text}"
    end

    # @param document [Bade::Document]
    #
    def visit_document(document)
      @documents.append(document)

      document.sub_documents.each do |sub_document|
        visit_document(sub_document)
      end

      buff_code("# ----- start file #{document.file_path}") unless document.file_path.nil?

      new_root = if @optimize
                   Optimizer.new(document.root).optimize
                 else
                   document.root
                 end

      visit_node(new_root)

      buff_code("# ----- end file #{document.file_path}") unless document.file_path.nil?

      @documents.pop
    end

    # @param current_node [Node]
    #
    def visit_node_children(current_node)
      visit_nodes(current_node.children)
    end

    # @param nodes [Array<Node>]
    #
    def visit_nodes(nodes)
      nodes.each do |node|
        visit_node(node)
      end
    end

    # @param current_node [Node]
    #
    def visit_node(current_node)
      update_location_node(current_node)

      case current_node.type
      when :root
        visit_node_children(current_node)

      when :static_text
        buff_print_static_text(current_node.value)

      when :tag
        visit_tag(current_node)

      when :code
        buff_code(current_node.value)

      when :html_comment
        buff_print_text '<!-- '
        visit_node_children(current_node)
        buff_print_text ' -->'

      when :comment
        comment_text = "##{current_node.children.map(&:value).join("\n#")}"
        buff_code(comment_text)

      when :doctype
        buff_print_text current_node.xml_output

      when :mixin_decl
        visit_block_decl(current_node)

      when :mixin_call
        params = formatted_mixin_params(current_node)
        buff_code "#{MIXINS_NAME}['#{current_node.name}'].call!(#{params})"

      when :output
        data = current_node.value
        output_code = if current_node.escaped
                        "\#{__html_escaped(#{data})}"
                      else
                        "\#{#{data}}"
                      end
        buff_print_text output_code

      when :newline
        # no-op
      when :import
        base_path = File.expand_path(current_node.value, File.dirname(@documents.last.file_path))
        load_path = if base_path.end_with?('.rb') && File.exist?(base_path)
                      base_path
                    elsif File.exist?("#{base_path}.rb")
                      "#{base_path}.rb"
                    end

        buff_code "__load('#{load_path}')" unless load_path.nil?
      when :yield
        block_name = DEFAULT_BLOCK_NAME
        method = current_node.conditional ? 'call' : 'call!'
        buff_code "#{block_name}.#{method}"
      else
        raise "Unknown type #{current_node.type}"
      end
    end

    # @param [TagNode] current_node
    #
    # @return [nil]
    #
    def visit_tag(current_node)
      attributes = formatted_attributes(current_node)
      children_wo_attributes = (current_node.children - current_node.attributes)

      text = "<#{current_node.name}"

      text += attributes.to_s unless attributes.empty?

      other_than_new_lines = children_wo_attributes.any? { |n| n.type != :newline }

      text += if other_than_new_lines
                '>'
              else
                '/>'
              end

      conditional_nodes = current_node.children.select { |n| n.type == :output && n.conditional }

      unless conditional_nodes.empty?
        buff_code "if (#{conditional_nodes.map(&:value).join(') && (')})"

        @code_indent += 1
      end

      buff_print_text(text, new_line: true, indent: true)

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

        buff_print_text("</#{current_node.name}>", new_line: true, indent: true)

        # print new line after the tag
        visit_node(last_node) if is_last_newline
      end

      unless conditional_nodes.empty? # rubocop:disable Style/GuardClause
        @code_indent -= 1

        buff_code 'end'
      end
    end

    # @param [TagNode] tag_node
    #
    # @return [String] formatted attributes
    #
    def formatted_attributes(tag_node)
      all_attributes = Hash.new { |hash, key| hash[key] = [] }
      xml_attributes = []

      tag_node.attributes.each do |attr|
        xml_attributes << attr.name unless all_attributes.include?(attr.name)

        all_attributes[attr.name] << attr.value
      end

      xml_attributes.map do |attr_name|
        joined = all_attributes[attr_name].join('), (')
        "\#{__tag_render_attribute('#{attr_name}', (#{joined}))}"
      end.join
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

    # @param [MixinCommonNode] mixin_node
    #
    # @return [String] formatted params
    #
    def formatted_mixin_params(mixin_node)
      params = mixin_node.params
      result = []

      case mixin_node.type
      when :mixin_call
        blocks = mixin_node.blocks

        other_children = (mixin_node.children - mixin_node.blocks - mixin_node.params)
        if other_children.count { |n| n.type != :newline } > 0
          def_block_node = AST::NodeRegistrator.create(:mixin_block, mixin_node, lineno: mixin_node.lineno)
          def_block_node.name = DEFAULT_BLOCK_NAME
          def_block_node.children = other_children

          blocks << def_block_node
        end

        if blocks.empty?
          result << '{}'
        else
          buff_code '__blocks = {}'

          blocks.each do |block|
            block_definition(block)
          end

          result << '__blocks.dup'
        end
      when :mixin_decl
        result << '__blocks'
      end

      # positional params
      result += params.select { |n| n.type == :mixin_param }
                      .map { |param| param.default_value ? "#{param.value} = #{param.default_value}" : param.value }

      # key-value params
      result += params.select { |n| n.type == :mixin_key_param }
                      .map { |param| "#{param.name}: #{param.value}" }

      result.join(', ')
    end

    # Generates code for definition of block
    #
    # @param [MixinCallBlockNode] block_node
    #
    # @return [nil]
    #
    def block_definition(block_node)
      buff_code "__blocks['#{block_node.name}'] = __create_block('#{block_node.name}', #{location_node(block_node)}) do"

      code_indent do
        visit_node_children(block_node)
      end

      buff_code 'end'
    end

    # Generates code for block variables declaration in mixin definition
    #
    # @param [String] block_name
    #
    # @return [nil]
    #
    def block_name_declaration(block_name)
      buff_code "#{block_name} = __blocks.delete('#{block_name}') { __create_block('#{block_name}') }"
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

      buff_code "#{MIXINS_NAME}['#{current_node.name}'] = __create_mixin(" \
                "'#{current_node.name}', #{location_node(current_node)}, &lambda { |#{params}|"

      code_indent do
        blocks_name_declaration(current_node)
        visit_nodes(current_node.children - current_node.params)
      end

      buff_code '})'
    end

    # @param [String] str
    #
    # @return [Void]
    #
    def escape_double_quotes!(str)
      str.gsub!(/"/, '\"')
    end

    # @param [Bade::AST::Node]
    # @return [Void]
    def update_location_node(node)
      should_skip = case node.type
                    when :code
                      value = node.value.strip

                      value.match(/^(end|else|\}|class)\b/) || value.match(/^(when|elsif) /) || value.match(/^\./)
                    when :newline
                      true
                    else
                      false
                    end

      return if should_skip
      return if node.lineno.nil?

      buff_code "__update_lineno(#{node.lineno})"
    end

    # @param [String] filename
    # @param [Fixnum] lineno
    # @param [String] label
    # @return [String]
    def location(filename:, lineno:, label:)
      args = [
        filename ? "path: '#{filename}'" : nil,
        "lineno: #{lineno}",
        "label: '#{label}'",
      ].compact

      "Location.new(#{args.join(',')})"
    end

    # @param [Node] node
    # @return [String]
    def location_node(node)
      label = case node.type
              when :mixin_decl
                "+#{node.name}"
              when :mixin_block
                "#{node.name} in +#{node.parent.name}"
              else
                node.name
              end

      location(filename: node.filename, lineno: node.lineno, label: label)
    end

    # Fix require_relative paths to be relative to the main Bade file (instead of the current file)
    #
    # @param [String] text
    # @return [String]
    #
    def _fix_required_relative(text)
      text.gsub(REQUIRE_RELATIVE_REGEX) do
        quote = Regexp.last_match[1]
        relative_path = Regexp.last_match[2]

        should_not_process = quote == '"' && relative_path.include?('#{')

        new_relative_path = relative_path
        unless should_not_process
          abs_path = File.expand_path(relative_path, File.dirname(@documents.last.file_path))
          document_abs_path = Pathname.new(File.expand_path(File.dirname(@documents.first.file_path)))
          new_relative_path = Pathname.new(abs_path).relative_path_from(document_abs_path).to_s
        end

        "require_relative #{quote}#{new_relative_path}#{quote}"
      end
    end
  end

  # backward compatibility
  RubyGenerator = Generator
end
