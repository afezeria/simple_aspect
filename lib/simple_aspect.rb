# frozen_string_literal: true

require_relative "simple_aspect/version"

module SimpleAspect
  class Impl
    # @param function [Proc] called method
    # @param method_name [String] method name
    # @param this [SimpleAspect] subclass instance of SimpleAspect
    # @param args [Array] method parameters
    def around(function, method_name, this, *args, &block)
      function.call(method_name, this, *args, &block)
    end
  end

  @@impls = {}

  def self.add_impl(sym, impl_obj)
    @@impls[sym] = impl_obj if impl_obj.is_a? Impl
  end

  def aspect(*flags)
    @aspect = true
    @flags = flags
  end

  def method_added(method_name)
    if @aspect
      @aspect = false
      flags = @flags
      @flags = nil
      original_method_name = :"_original_method_#{method_name}"
      alias_method original_method_name, method_name
      original = proc { |_, this, *args, &block|
        this.send(original_method_name, *args, &block)
      }
      flags.reverse!
      real = flags.reduce(original) do |acc, sym|
        proc { |name, this, *args, &block|
          impl = @@impls[sym]
          if impl
            impl.around(acc, name, this, *args, &block)
          else
            acc.call(name, this, *args, &block)
          end
        }
      end
      define_method method_name do |*args, &block|
        real.call(method_name, self, *args, &block)
      end
    end
  end
end
