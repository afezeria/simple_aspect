# SimpleAspect

## Deprecated

simple_aspect is deprecated.

## about

simple_aspect allows to use AOP in ruby in a way similar to Java annotation

## Examples

```ruby

class A
  extend SimpleAspect

  aspect :log1, :log2

  def abc
    puts 'abc'
  end
end

class LogAspectImpl < SimpleAspect::Impl

  def initialize(num = 1)
    @num = num
  end

  def around(function, method_name, this, *args, &block)
    puts "log #{@num} invoke #{method_name}"
    function.call(method_name, this, *args, &block)
  end
end

SimpleAspect.add_impl :log1, LogAspectImpl.new
SimpleAspect.add_impl :log2, LogAspectImpl.new(2)

A.new.abc

# Expected output
# log 1 invoke abc 
# log 2 invoke abc 
# abc
```