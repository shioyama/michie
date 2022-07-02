RSpec.describe Michie do
  before do
    stub_const("Listener", double("listener"))
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

    expect(foo.instance_variables).to eq([:"@__michie_my_method"])
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
      :"@__michie_my_method",
      :"@__michie_my_method_bang",
      :"@__michie_my_method_query"
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

    expect(foo.instance_variables).to eq([:"@foo_my_method"])
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
