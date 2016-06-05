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
      @document = document
      @buff = []
      @indent = 0
      @code_indent = 0
      @optimize = optimize

      buff_code '# frozen_string_literal: true' # so it can be faster on Ruby 2.3+
      buff_code ''
      buff_code "lambda do |#{NEW_LINE_NAME}: \"\\n\", #{BASE_INDENT_NAME}: '  '|"

        buff_code "  self.#{NEW_LINE_NAME} = #{NEW_LINE_NAME}"
        buff_code "  self.#{BASE_INDENT_NAME} = #{BASE_INDENT_NAME}"

        visit_document(document)

        buff_code "  output = #{BUFF_NAME}.join"
        buff_code '  self.__reset'
        buff_code '  output'

      buff_code 'end'


      @document = nil

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
      buff_print_value("'#{text.gsub("'", "\\'")}'") unless text.empty?
    end

    def buff_print_value(value)
      # buff_code %Q{#{BUFF_NAME} << #{CURRENT_INDENT_NAME}} if indent
      buff_code("#{BUFF_NAME} << #{value}")
    end

    def buff_code(text)
      @buff << '  ' * @code_indent + text
    end


    # @param document [Bade::Document]
    #
    def visit_document(document)
      document.sub_documents.each do |sub_document|
        visit_document(sub_document)
      end

      buff_code("# ----- start file #{document.file_path}") unless document.file_path.nil?

      instructions = if @optimize
                   Optimizer.new(Assembler.new(document).assembly).optimize
                 else
                   Assembler.new(document).assembly
                 end

      instructions.each do |i|
        case i.type
        when :static_text
          buff_print_static_text(i.value)
        when :dynamic_value
          buff_print_value(i.value)
        when :code
          buff_code(i.value)
        end
      end

      buff_code("# ----- end file #{document.file_path}") unless document.file_path.nil?
    end

    # @param [String] str
    #
    # @return [Void]
    #
    def escape_double_quotes!(str)
      str.gsub!(/"/, '\"')
    end
  end

  # backward compatibility
  RubyGenerator = Generator
end
