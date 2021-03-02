# frozen_string_literal: true
class TestClass
  extend SimpleAspect

  aspect :log, :params

  def abc(m = 1)
    m
  end
end

class TestLogger < SimpleAspect::Impl
  @@log = []

  class << self
    def log
      @@log
    end
  end

  def around(function, method_name, this, *args, &block)
    @@log.push "invoke #{method_name}"
    function.call(method_name, this, *args, &block)
  end
end

class ModifyMethodParameter < SimpleAspect::Impl

  def around(function, method_name, this, *args, &block)
    args[0] = 10 unless args.empty?
    function.call(method_name, this, *args, &block)
  end
end

SimpleAspect.add_impl :log, TestLogger.new

RSpec.describe SimpleAspect do
  it "has a version number" do
    expect(SimpleAspect::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(TestLogger.log.empty?).to eq(true)
    TestClass.new.abc
    expect(TestLogger.log.empty?).to eq(false)
    expect(TestLogger.log[0]).to eq('invoke abc')
  end

  it "modify method parameters" do
    SimpleAspect.add_impl :params, ModifyMethodParameter.new
    result = TestClass.new.abc(5)
    expect(result).to eq(10)
  end
end
