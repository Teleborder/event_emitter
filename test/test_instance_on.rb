require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestInstanceOn < MiniTest::Test

  class Foo
    include EventEmitter
    def created_at
      @created_at
    end
    def created_at=(time)
      @created_at = time
    end
  end

  def setup
    @foo = Foo.new
    @foo.created_at = @now = Time.now
  end

  def test_extends
    assert Foo.respond_to? :emit
    assert Foo.respond_to? :instance_on
  end

  def test_simple
    created_at = nil
    Foo.instance_on :bar do
      created_at = self.created_at
    end
    @foo.emit :bar

    assert created_at == @now
  end

  def test_on_emit
    result = nil
    created_at = nil
    Foo.instance_on :chat do |data|
      result = data
      created_at = self.created_at
    end

    @foo.emit :chat, :user => 'shokai', :message => 'hello world'

    assert result[:user] == 'shokai'
    assert result[:message] == 'hello world'
    assert created_at == @now, 'instance method'
  end

  def test_on_emit_multiargs
    _user = nil
    _message = nil
    _session = nil
    created_at = nil
    Foo.instance_on :chat2 do |user, message, session|
      _user = user
      _message = message
      _session = session
      created_at = self.created_at
    end

    sid = Time.now.to_i
    @foo.emit :chat2, 'shokai', 'hello world', sid

    assert _user == 'shokai'
    assert _message == 'hello world'
    assert _session == sid
    assert created_at == @now, 'instance method'
  end

  def test_add_instance_listener
    result = nil
    created_at = nil
    Foo.add_instance_listener :chat do |data|
      result = data
      created_at = self.created_at
    end

    @foo.emit :chat, :user => 'shokai', :message => 'hello world'

    assert result[:user] == 'shokai'
    assert result[:message] == 'hello world'
    assert created_at == @now, 'instance method'
  end

  def test_once
    total = 0
    Foo.instance_once :add do |data|
      total += data
    end

    @foo.emit :add, 1
    assert total == 1, 'first call'
    @foo.emit :add, 1
    assert total == 1, 'call listener only first time'
  end
end
