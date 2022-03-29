# frozen_string_literal: true

require_relative '../helper'

# just to stop RuboCop from complaining about missing parameters
def eval_function(text)
  eval(text, binding, File.join(__dir__, 'template'), __LINE__ + 1)
end

describe Bade::Runtime::GlobalsTracker do
  before(:each) do
    @sut = Bade::Runtime::GlobalsTracker.new
  end

  context 'variables' do
    it 'will catch new global variables created in given block' do
      @sut.catch do
        eval_function(<<-RB)
          $new_global_variable1 = 'abc'
        RB
      end

      expect(@sut.caught_variables).to contain_exactly :$new_global_variable1
    end

    it 'can remove global variable' do
      @sut.catch do
        eval_function(<<-RB)
          $new_global_variable2 = 'abc'
        RB
      end

      expect(eval_function('$new_global_variable2')).to eq 'abc'

      @sut.clear_all

      expect(eval_function('$new_global_variable2')).to be_nil
    end
  end

  context 'constants' do
    it 'will catch new constants created in given block' do
      @sut.catch do
        eval_function(<<-RB)
          NEW_GLOBAL_CONSTANT1 = 'abc'

          class Test1; end

          module Abc
            class AbcClass
            end
          end
        RB
      end

      expect(@sut.caught_constants.map { |(_, name)| name }).to contain_exactly :NEW_GLOBAL_CONSTANT1, :Test1, :Abc
    end

    it 'can remove caught constants' do
      @sut.catch do
        eval_function(<<-RB)
          NEW_GLOBAL_CONSTANT2 = 'abc'

          class Test2
            def abc; end
          end
        RB
      end

      expect(eval_function('NEW_GLOBAL_CONSTANT2')).to eq 'abc'

      @sut.clear_all

      expect do
        eval_function('NEW_GLOBAL_CONSTANT2')
      end.to raise_error(NameError)
      expect do
        eval_function('Test2')
      end.to raise_error(NameError)
    end

    it 'will not remove constants from required files' do
      @sut.catch do
        eval_function('require_relative "imported"')
      end

      expect($LOADED_FEATURES).to include(File.join(__dir__, 'imported.rb'))
      expect(eval_function('ImportedModuleAbc.upcase("abc")')).to eq 'ABC'

      @sut.clear_all

      expect($LOADED_FEATURES).to include(File.join(__dir__, 'imported.rb'))
      expect(eval_function('ImportedModuleAbc.upcase("abc")')).to eq 'ABC'
    end
  end
end
