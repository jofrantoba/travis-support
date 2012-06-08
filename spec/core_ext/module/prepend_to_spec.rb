require 'spec_helper'
require 'core_ext/module/prepend_to'

describe 'Module.prepend_to' do
  let(:klass) do
    Class.new do
      def called
        @called ||= []
      end

      def foo(*args)
        called << :original
      end
    end
  end

  let(:object) { klass.new }
  let(:method) { klass.instance_method(:foo) }

  def prepend!(arg = nil)
    klass.prepend_to :foo do |_super, *args|
      object.called << arg
      _super.call(*args)
    end
  end

  it 'pushes the implementation down to a module' do
    prepend!
    klass.included_modules.first.instance_method(:foo).should_not be_nil
  end

  it 'defines the new method on the given module' do
    prepend!
    klass.instance_method(:foo).should_not be_nil
  end

  it 'calls the given method first and the original method second' do
    prepend!(:prepended)
    object.foo
    object.called.should == [:prepended, :original]
  end

  it 'can be called multiple times' do
    1.upto(3) { |n| prepend!(n) }
    object.foo
    object.called.should == [3, 2, 1, :original]
  end
end