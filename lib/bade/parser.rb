
require_relative 'node'
require_relative 'ruby_extensions/string'

module Bade
	class Parser
		class SyntaxError < StandardError
			attr_reader :error, :file, :line, :lineno, :column

			def initialize(error, file, line, lineno, column)
				@error = error
				@file = file || '(__TEMPLATE__)'
				@line = line.to_s
				@lineno = lineno
				@column = column
			end

			def to_s
				line = @line.lstrip
				column = @column + line.size - @line.size
				%{#{error}
	#{file}, Line #{lineno}, Column #{@column}
	#{line}
	#{' ' * column}^
}
			end
		end

		class ParserInternalError < StandardError; end

		# Initialize
		#
		# Available options:
		#   :tabsize [Int]    default 4
		#   :file [String]    default nil
		#
		def initialize(options = {})
      @line = ''

			tabsize = options.delete(:tabsize) { 4 }
			@tabsize = tabsize

			@tab_re = /\G((?: {#{tabsize}})*) {0,#{tabsize-1}}\t/
			@tab = '\1' + ' ' * tabsize

			@options = options

			reset
		end

		# @param [String, Array<String>] str
		# @return [Node] root node
		#
		def parse(str)
			@root = Node.new(:root)

      if str.kind_of? Array
        reset(str, [[@root]])
      else
        reset(str.split(/\r?\n/), [[@root]])
      end

			parse_line while next_line

			reset

			@root
		end



		WORD_RE = ''.respond_to?(:encoding) ? '\p{Word}' : '\w'
		NAME_RE_STRING = "(#{WORD_RE}(?:#{WORD_RE}|:|-|_)*)"

		ATTR_NAME_RE_STRING = "\\A\\s*#{NAME_RE_STRING}"
		CODE_ATTR_RE = /#{ATTR_NAME_RE_STRING}\s*(&?):\s*/

		TAG_RE = /\A#{NAME_RE_STRING}/
		CLASS_TAG_RE = /\A\.#{NAME_RE_STRING}/
		ID_TAG_RE = /\A##{NAME_RE_STRING}/

		def reset(lines = nil, stacks = nil)
			# Since you can indent however you like in Slim, we need to keep a list
			# of how deeply indented you are. For instance, in a template like this:
			#
			#   doctype       # 0 spaces
			#   html          # 0 spaces
			#    head         # 1 space
			#       title     # 4 spaces
			#
			# indents will then contain [0, 1, 4] (when it's processing the last line.)
			#
			# We uses this information to figure out how many steps we must "jump"
			# out when we see an de-indented line.
			@indents = [0]

			# Whenever we want to output something, we'll *always* output it to the
			# last stack in this array. So when there's a line that expects
			# indentation, we simply push a new stack onto this array. When it
			# processes the next line, the content will then be outputted into that
			# stack.
			@stacks = stacks

			@lineno = 0
			@lines = lines

			# @return [String]
			@line = @orig_line = nil
		end

		def next_line
			if @lines.empty?
				@orig_line = @line = nil
			else
				@orig_line = @lines.shift
				@lineno += 1
				@line = @orig_line.dup
			end
		end

		# Calculate indent for line
		#
		# @param [String] line
		#
		# @return [Int] indent size
		#
		def get_indent(line)
			line.get_indent(@tabsize)
		end

		# Append element to stacks and result tree
		#
		# @param [Symbol] type
		#
		def append_node(type, indent: @indents.length, add: false, data: nil)
			while indent >= @stacks.length
				@stacks << @stacks.last.dup
			end

			parent = @stacks[indent].last
			node = Node.create(type, parent)
			node.lineno = @lineno

			node.data = data

			if add
				@stacks[indent] << node
			end

			node
		end

		def parse_line
			line = @line

			if line =~ /\A\s*\Z/
				append_node :newline
				return
			end

			indent = get_indent(line)

			# left strip
			line.remove_indent!(indent, @tabsize)
			@line = line

			# If there's more stacks than indents, it means that the previous
			# line is expecting this line to be indented.
			expecting_indentation = @stacks.length > @indents.length

			if indent > @indents.last
				@indents << indent
			else
				# This line was *not* indented more than the line before,
				# so we'll just forget about the stack that the previous line pushed.
				@stacks.pop if expecting_indentation

				# This line was deindented.
				# Now we're have to go through the all the indents and figure out
				# how many levels we've deindented.
				while indent < @indents.last
					@indents.pop
					@stacks.pop
				end

				# Remove old stacks we don't need
				while not @stacks[indent].nil? and indent < @stacks[indent].length - 1
					@stacks[indent].pop
				end

				# This line's indentation happens lie "between" two other line's
				# indentation:
				#
				#   hello
				#       world
				#     this      # <- This should not be possible!
				syntax_error('Malformed indentation') if indent != @indents.last
			end

			parse_line_indicators
		end

		def parse_line_indicators
			case @line

				when /\Amixin #{NAME_RE_STRING}/
					# Mixin declaration
					@line = $'
					parse_mixin_declaration($1)

				when /\A\+#{NAME_RE_STRING}/
					# Mixin call
					@line = $'
					parse_mixin_call($1)

				when /\Ablock #{NAME_RE_STRING}/
					@line = $'
					if @stacks.last.last.type == :mixin_call
						append_node :mixin_block, data: $1, add: true
					else
						# keyword block used outside of mixin call
						parse_tag($&)
					end

				when /\A\/\/! /
					# HTML comment
					append_node :html_comment, add: true
					parse_text_block $'

				when /\A\/\//
					# Comment
					append_node :comment, add: true
					parse_text_block $'

				when /\A\|( ?)/
					# Found a text block.
					parse_text_block $', @indents.last + @tabsize

				when /\A</
					# Inline html
					parse_text_block @line, @indents.last + @tabsize

				when /\A-\s(.*)\Z/
					# Found a code block.
					code_node = append_node :ruby_code
					code_node.data = $1

				when /\A(&?)=/
					# Found an output block.
					# We expect the line to be broken or the next line to be indented.
					@line = $'
					output_node = append_node :output
          output_node.escaped = $1.length == 1
					output_node.data = parse_ruby_code("\n")

				when /\A(\w+):\s*\Z/
					# Embedded template detected. It is treated as block.
					@stacks.last << [:slim, :embedded, $1, parse_text_block]

				when /\Adoctype\s/i
					# Found doctype declaration
					append_node :doctype, data: $'.strip

				when TAG_RE
					# Found a HTML tag.
					@line = $' if $1
					parse_tag($&)

				when /\A\./
					# Found class name -> implicit div
					parse_tag 'div'

				when /\A#/
					# Found id name -> implicit div
					parse_tag 'div'

				else
					syntax_error 'Unknown line indicator'
			end

			append_node :newline
		end

		def parse_mixin_call(mixin_name)
			mixin_node = append_node :mixin_call, add: true
			mixin_node.data = mixin_name

			parse_mixin_call_params

			case @line
				when /\A /
					@line = $'
					parse_text

				when /\A:\s+/
					# Block expansion
					@line = $'
					parse_line_indicators

				when /\A(&?)=/
					# Handle output code
					parse_line_indicators

				when /^$/
					# nothing

				else
					syntax_error "Unknown symbol after mixin calling"
			end
		end

		def parse_mixin_call_params
			# between tag name and attribute must not be space
			# and skip when is nothing other
			if @line =~ /\A\(/
				@line = $'
			else
				return
			end

			end_re = /\A\s*\)/

			while true
				case @line
					when CODE_ATTR_RE
						@line = $'
						attr_node = append_node :mixin_key_param
						attr_node.name = $1
						attr_node.value = parse_ruby_code(',)')

					when /\A\s*,/
						# args delimiter
						@line = $'
						next

					when end_re
						# Find ending delimiter
						@line = $'
						break

					else
						attr_node = append_node :mixin_param
						attr_node.data = parse_ruby_code(',)')
				end
			end
		end

		def parse_mixin_declaration(mixin_name)
			mixin_node = append_node :mixin_declaration, add: true
			mixin_node.data = mixin_name

			parse_mixin_declaration_params
		end

		def parse_mixin_declaration_params
			# between tag name and attribute must not be space
			# and skip when is nothing other
			if @line =~ /\A\(/
				@line = $'
			else
				return
			end

			end_re = /\A\s*\)/

			while true
				case @line
					when CODE_ATTR_RE
						# Value ruby code
						@line = $'
						attr_node = append_node :mixin_key_param
						attr_node.name = $1
						attr_node.value = parse_ruby_code(',)')

					when /\A\s*#{NAME_RE_STRING}/
						@line = $'
						append_node :mixin_param, data: $1

					when /\A\s*&#{NAME_RE_STRING}/
						@line = $'
						append_node :mixin_block_param, data: $1

					when /\A\s*,/
						# args delimiter
						@line = $'
						next

					when end_re
						# Find ending delimiter
						@line = $'
						break

					else
						syntax_error('wrong mixin attribute syntax')
				end
			end
		end

		def parse_text
			text = @line
			text = text.gsub(/&\{/, '#{ html_escaped ')
			append_node :text, data: text
		end

		# @param [String] tag  tag name
		#
		def parse_tag(tag)

			if tag =~ /(:)\Z/
				tag.gsub! /:\Z/, ''
				@line.prepend ':'
			end

			if tag.is_a? Node
				tag_node = tag
			else
				tag_node = append_node :tag, add: true
				tag_node.name = tag
			end

			parse_tag_attributes

			case @line
				when /\A:\s+/
					# Block expansion
					@line = $'
					parse_line_indicators

				when /\A(&?)=/
					# Handle output code
          parse_line_indicators

				when CLASS_TAG_RE
					# Class name
					attr_node = append_node :tag_attribute
					attr_node.name = 'class'
					attr_node.value = $1.single_quote
					@line = $'

					parse_tag tag_node

				when ID_TAG_RE
					# Id name
					attr_node = append_node :tag_attribute
					attr_node.name = 'id'
					attr_node.value = $1.single_quote

					@line = $'

					parse_tag tag_node

				when /\A /
					# Text content
					@line = $'
					parse_text

				when /^$/
					# nothing

				else
					syntax_error "Unknown symbol after tag definition #{@line}"
			end
		end

		def parse_tag_attributes
			# Check to see if there is a delimiter right after the tag name

			# between tag name and attribute must not be space
			# and skip when is nothing other
			if @line =~ /\A\(/
				@line = $'
			else
				return
			end

			end_re = /\A\s*\)/

			while true
				case @line
					when CODE_ATTR_RE
						# Value ruby code
						@line = $'
						attr_node = append_node :tag_attribute
						attr_node.name = $1
						attr_node.value = parse_ruby_code(',)')

					when /\A\s*,/
						# args delimiter
						@line = $'
						next

          when end_re
            # Find ending delimiter
            @line = $'
            break

          else
            # Found something where an attribute should be
            @line.lstrip!
            syntax_error('Expected attribute') unless @line.empty?

            # Attributes span multiple lines
            @stacks.last << [:newline]
            syntax_error("Expected closing delimiter #{delimiter}") if @lines.empty?
            next_line
        end
			end
		end

		def parse_text_block(first_line, text_indent = nil)
			if !first_line || first_line.empty?
				text_indent = nil
			else
				@line = first_line
				parse_text
			end

			until @lines.empty?
				if @lines.first =~ /\A\s*\Z/
					next_line
					append_node :newline
				else
					indent = get_indent(@lines.first)
					break if indent <= @indents.last

					next_line

					@line.remove_indent!(text_indent ? text_indent : indent, @tabsize)

					parse_text

					# The indentation of first line of the text block
					# determines the text base indentation.
					text_indent ||= indent
				end
			end
		end

		# Parse ruby code, ended with outer delimiters
		#
		# @param [String] outer_delimiters
		#
		# @return [Void] parsed ruby code
		#
		def parse_ruby_code(outer_delimiters)
			code = ''
			end_re = /\A\s*[#{Regexp.escape outer_delimiters.to_s}]/
			delimiters = []

			until @line.empty? or (delimiters.count == 0 and @line =~ end_re)
				char = @line[0]

				# backslash escaped delimiter
				if char == '\\' && RUBY_ALL_DELIMITERS.include?(@line[1])
					code << @line.slice!(0, 2)
					next
				end

				case char
					when RUBY_START_DELIMITERS_RE
						if RUBY_NOT_NESTABLE_DELIMITERS.include?(char) && delimiters.last == char
							# end char of not nestable delimiter
							delimiters.pop
						else
							# diving
							delimiters << char
						end

					when RUBY_END_DELIMITERS_RE
						# rising
						if char == RUBY_DELIMITERS_REVERSE[delimiters.last]
							delimiters.pop
						end
				end

				code << @line.slice!(0)
			end

			unless delimiters.empty?
				syntax_error('Unexpected end of ruby code')
			end

			code.strip
		end

		RUBY_DELIMITERS_REVERSE = {
			'(' => ')',
			'[' => ']',
			'{' => '}'
		}.freeze

		RUBY_QUOTES = %w(' ").freeze

		RUBY_NOT_NESTABLE_DELIMITERS = (RUBY_QUOTES + %w( | )).freeze

		RUBY_START_DELIMITERS = (%w(\( [ {) + RUBY_NOT_NESTABLE_DELIMITERS).freeze
		RUBY_END_DELIMITERS = (%w(\) ] }) + RUBY_NOT_NESTABLE_DELIMITERS).freeze
		RUBY_ALL_DELIMITERS = (RUBY_START_DELIMITERS + RUBY_END_DELIMITERS).uniq.freeze

		RUBY_START_DELIMITERS_RE = /\A[#{Regexp.escape RUBY_START_DELIMITERS.join('')}]/
		RUBY_END_DELIMITERS_RE = /\A[#{Regexp.escape RUBY_END_DELIMITERS.join('')}]/


		# ----------- Errors ---------------

		# Raise specific error
		#
		# @param [String] message
		#
		def syntax_error(message)
			raise SyntaxError.new(message, @options[:file], @orig_line, @lineno,
								  @orig_line && @line ? @orig_line.size - @line.size : 0)
		end
	end
end
