# frozen-string-literal: true
require "michie/version"

module Michie
  DEFAULT_IVAR_PREFIX = "__michie"

  def memoize(eager: false, prefix: DEFAULT_IVAR_PREFIX, &block)
    methods_before = instance_methods(false)
    block.call
    methods_to_memoize = instance_methods(false) - methods_before

    memoizer = eager ? EagerMemoizer : Memoizer

    prepend(memoizer.new(methods_to_memoize, prefix))
  end

  class Memoizer < Module
    def initialize(methods_to_memoize, prefix)
      methods_to_memoize.each do |method_name|
        define_memoized_method(method_name, prefix)
      end
    end

    def define_memoized_method(method_name, prefix)
      ivar = Helpers.ivar_name(method_name, prefix)
      module_eval <<-EOM, __FILE__, __LINE__ + 1
        def #{method_name}
          return #{ivar} if defined?(#{ivar})

          result = super
          #{ivar} = result
          result
        end
      EOM
    end

    def inspect
      "<##{self.class} (methods: #{instance_methods(false).join(", ")})>"
    end
  end

  class EagerMemoizer < Memoizer
    def prepended(klass)
      klass.include(Initializer)
    end

    module Initializer
      def initialize(*, &block)
        super

        self.class.ancestors.grep(EagerMemoizer).each do |mod|
          mod.instance_methods(false).each { |m| send(m) }
        end
      end
    end
  end

  module Helpers
    def ivar_name(method_name, memoization_prefix)
      string = "#{memoization_prefix}_#{method_name.to_s}"

      if string.end_with?("?", "!")
        string = string.dup
        string.sub!(/\?\Z/, "_query") || string.sub!(/!\Z/, "_bang")
      end
      "@#{string}"
    end
    module_function :ivar_name
  end
end
