require 'rspec'


  describe Bade::Parser do
    context '#parse_ruby_code' do
      def assert_ruby_code(source, expected_ruby, end_delimiter = ',)', options = {})
        sut = Bade::Parser.new(options)

        sut.instance_eval { @lines = [source] }
        sut.next_line

        result_ruby = sut.parse_ruby_code end_delimiter

        expect(result_ruby).to eq expected_ruby
      end

      it 'parse string' do
        assert_ruby_code ' "abc" ,', '"abc"'
      end
      it 'parse string with colons' do
        assert_ruby_code ' "abc ,fd ,, fds f" ,   ', '"abc ,fd ,, fds f"'
      end
      it 'parse string with mixed quotes' do
        source = %( "text with \\', \\" quotes" 'other, text ' )
        expected = %("text with \\', \\" quotes" 'other, text ')
        assert_ruby_code source, expected
      end

      it 'parse symbol definition' do
        assert_ruby_code(' :symbol', ':symbol')
        assert_ruby_code(' :symbol,', ':symbol')
      end

      it 'should not parse incomplete text' do
        source = ' some_method(param   , '

        expect do
          assert_ruby_code source, nil
        end.to raise_error(String)
      end

      it 'parse simple variable' do
        assert_ruby_code 'abc,', 'abc'
      end
      it 'parse simple variable with calling method' do
        assert_ruby_code 'abc.lowercase,', 'abc.lowercase'
      end

      it 'parse calling function with parameter' do
        assert_ruby_code 'function(abc)   ,', 'function(abc)'
      end
      it 'parse calling function with more parameters' do
        assert_ruby_code 'function(abc, 123)    ,', 'function(abc, 123)'
      end

      it 'parsed value is striped' do
        assert_ruby_code '    some code     ', 'some code'
      end

      it 'parse accessing with square brackets' do
        assert_ruby_code ' hash[text]   ,', 'hash[text]'
      end
      it 'parse accessing with square brackets with string' do
        assert_ruby_code ' hash["text"]   ,', 'hash["text"]'
      end
      it 'parse accessing with square brackets with multiple parameters' do
        assert_ruby_code ' hash[text,text2]   ,', 'hash[text,text2]'
      end

      it 'parse blocks' do
        assert_ruby_code '  hash.map { |baf| baf, baf }  ', 'hash.map { |baf| baf, baf }'
      end

      it 'parse multi lined code' do
        source = <<-BADE.strip_heredoc
          test code multi lined
            code
        BADE

        expected = <<-RESULT.strip_heredoc.rstrip
          test code multi lined
            code
        RESULT

        assert_ruby_code source, expected
      end
    end
  end
