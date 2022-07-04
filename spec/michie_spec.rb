RSpec.describe Michie do
  before do
    stub_const("Listener", double("listener"))
    stub_const("OtherListener", double("listener"))
  end

  it "has a version number" do
    expect(Michie::VERSION).not_to be nil
  end

  it "memoizes methods defined in a block" do
    klass = Class.new do
      extend Michie

      memoize do
        def my_method
          Listener.call
        end
      end
    end

    foo = klass.new
    expect(Listener).to receive(:call).once.and_return("result")

    2.times do
      expect(foo.my_method).to eq("result")
    end

    expect(foo.instance_variables).to eq([:"@__michie_m_my_method"])
  end

  it "memoizes methods passed as args" do
    klass = Class.new do
      extend Michie

      def method1
        Listener.call
      end
      def method2
        OtherListener.call
      end

      memoize :method1, :method2
    end

    foo = klass.new

    expect(Listener).to receive(:call).once.and_return("result")
    2.times { expect(foo.method1).to eq("result") }
    expect(foo.instance_variables).to eq([:"@__michie_m_method1"])

    expect(OtherListener).to receive(:call).once.and_return("result")
    2.times { expect(foo.method2).to eq("result") }
    expect(foo.instance_variables).to match_array(
      [:"@__michie_m_method1", :"@__michie_m_method2"]
    )
  end

  it "raises ArgumentError if passed both method(s) and block" do
    klass = Class.new do
      extend Michie
    end

    expect {
      klass.memoize(:foo) do
      end
    }.to raise_error(ArgumentError, "memoize takes method names or a block defining methods, not both.")
  end

  it "handles bang methods" do
    klass = Class.new do
      extend Michie

      memoize do
        def my_method!
          Listener.call
        end
      end
    end

    foo = klass.new
    expect(Listener).to receive(:call).once.and_return("result")

    2.times do
      expect(foo.my_method!).to eq("result")
    end
  end

  it "handles query methods" do
    klass = Class.new do
      extend Michie

      memoize do
        def my_method?
          Listener.call
        end
      end
    end

    foo = klass.new
    expect(Listener).to receive(:call).once.and_return("result")

    2.times do
      expect(foo.my_method?).to eq("result")
    end
  end

  it "memoizes to prefixed instance variables using __michie prefix" do
    klass = Class.new do
      extend Michie

      memoize do
        def my_method
        end

        def my_method!
        end

        def my_method?
        end
      end
    end

    foo = klass.new
    foo.my_method
    foo.my_method!
    foo.my_method?

    expect(foo.instance_variables).to match_array([
      :"@__michie_m_my_method",
      :"@__michie_b_my_method",
      :"@__michie_q_my_method"
    ])
  end

  it "accepts custom ivar prefix" do
    klass = Class.new do
      extend Michie

      memoize(prefix: "foo") do
        def my_method
        end
      end
    end

    foo = klass.new
    foo.my_method

    expect(foo.instance_variables).to eq([:"@foo_m_my_method"])
  end

  it "maintains visibility of memoized methods" do
    klass = Class.new do
      extend Michie

      memoize(prefix: "foo") do
        def public_method
        end

        def protected_method
        end
        protected :protected_method

        def private_method
        end
        private :private_method
      end
    end

    expect(klass.public_instance_methods).to include(:public_method)
    expect(klass.protected_instance_methods).to include(:protected_method)
    expect(klass.private_instance_methods).to include(:private_method)
  end

  it "accepts eager option to eager-evaluate methods" do
    klass = Class.new do
      extend Michie

      memoize(eager: true) do
        def my_method
          Listener.call
        end
      end
    end

    expect(Listener).to receive(:call).once.and_return("result")
    klass.new
  end
end
