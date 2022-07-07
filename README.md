# Michie

[![Gem Version](https://badge.fury.io/rb/michie.svg)][gem]
[![Build Status](https://github.com/shioyama/michie/actions/workflows/ruby.yml/badge.svg)][actions]

[gem]: https://rubygems.org/gems/michie
[actions]: https://github.com/shioyama/michie/actions

Michie (pronounced /ˈmɪki/, like “Mickey”) memoizes methods either passed by
method name or defined in a block. Unlike other meomization libraries, Michie
encapsulates its memoization in a single module which it prepends over the
original method.

## Installation

Add Michie to your gemfile:

```ruby
gem "michie", "~> 0.2.0"
```

## Usage

Simply extend a class with `Michie` and define methods in a block passed to the
`memoize` method:

```ruby
class BillingApi
  extend Michie

  memoize do
    def fetch_aggregate_data
      # time-consuming request
    end
  end
end
```

Alternatively, you can pass the method name(s) to `memoize` after they have
been defined:

```ruby
class BillingApi
  extend Michie

  def fetch_aggregate_data
    # ...
  end
  memoize :fetch_aggregate_data
end
```

The method(s) are now memoized:

```ruby
api = BillingApi.new
api.fetch_aggregate_data
#=> (calls original #fetch_aggregate_data method)

api.fetch_aggregate_data
#=> returns value memoized by Michie
```

Unlike other memoization libraries that use `alias_method` to reference the
original method, leaving artifacts in the including class, memoization in
Michie is encapsulated in a module.

This module is dynamically created and prepended by `Michie#memoize`:

```ruby
BillingApi.ancestors
#=> [<#Michie::Memoizer (methods: fetch_aggregate_data)>, BillingApi, Object, Kernel, BasicObject]

memoizer = BillingApi.ancestors[0]
memoizer.instance_methods(false)
#=> [:fetch_aggregate_data]
```

The memoizer method uses an instance variable to memoize the value returned
from the original method, and calls the original method with `super`:

```ruby
def fetch_aggregate_data
  return @__michie_m_fetch_aggregate_data if defined?(@__michie_m_fetch_aggregate_data)

  result = super
  @__michie_m_fetch_aggregate_data = result
  result
end
```

By default, Michie generates an instance variable name prefix combining a
"base" string `__michie_` with either an `m_` (normal methods), `b_` (bang
methods ending in `!`) or `q_` (query methods ending in `?`). This prefix is
combined with the name of the method to be memoized to generate the instance
variable name.  The base prefix can be changed by passing a `prefix` option to
`memoize` (see specs for details).

Since Michie uses the presence of an instance variable to signal memoization,
`false` and `nil` values can be memoized (unlike techniques which use `||=`).
Michie also respects method visibility, so you can use it to memoize your
private and protected methods.

Passing `eager: true` to `memoize` will eagerly call all methods defined in the
`memoize` block as soon as an instance is created:

```ruby
class BillingApi
  extend Michie

  memoize(eager: true) do
    def fetch_aggregate_data
      # ...
    end
  end
end

api = BillingApi.new
# `fetch_agregate_data` has already been memoized
```

Beware that Michie does not memoize methods that take arguments; this is
a design decision to make the code as simple and readable as possible.

## Reference

The gem is named after [Donald
Michie](https://en.wikipedia.org/wiki/Donald_Michie) (1923-2007), the British AI
researcher who invented memoization. Not to be confused with a [Rust memoization
library](https://docs.rs/michie/latest/michie/) with the same name.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
