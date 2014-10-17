module EventEmitter
  def self.included(klass)
    klass.extend ClassMethods
    klass.__send__ :include, InstanceMethods
  end

  def self.apply(object)
    object.extend InstanceMethods
  end

  module InstanceMethods
    def __events
      @__events ||= []
    end

    def add_listener(type, params={}, &block)
      raise ArgumentError, 'listener block not given' unless block_given?
      id = __events.empty? ? 0 : __events.last[:id]+1
      __events << {
        :type => type.to_sym,
        :listener => block,
        :params => params,
        :id => id
      }
      id
    end

    alias :on :add_listener

    def add_listener_to_instance(type, params={}, &block)

    end

    def remove_listener(id_or_type)
      if id_or_type.class == Fixnum
        __events.delete_if do |e|
          e[:id] == id_or_type
        end
      elsif [String, Symbol].include? id_or_type.class
        __events.delete_if do |e|
          e[:type] == id_or_type.to_sym
        end
      end
    end

    def emit(type, *data)
      type = type.to_sym
      __events.each do |e|
        case e[:type]
        when type
          listener = e[:listener]
          e[:type] = nil if e[:params][:once]
          instance_exec(*data, &listener)
        when :*
          listener = e[:listener]
          e[:type] = nil if e[:params][:once]
          instance_exec(type, *data, &listener)
        end
      end
      __events.each do |e|
        remove_listener e[:id] unless e[:type]
      end
      self.class.instance_emit(self, type, *data) if self.class.respond_to? :instance_emit
    end

    def once(type, &block)
      add_listener type, {:once => true}, &block
    end

  end

  module ClassMethods
    include InstanceMethods

    def __instance_events
      @__instance_events ||= []
    end

    def add_instance_listener(type, params={}, &block)
      raise ArgumentError, 'listener block not given' unless block_given?
      id = __instance_events.empty? ? 0 : __instance_events.last[:id]+1
      __instance_events << {
        :type => type.to_sym,
        :listener => block,
        :params => params,
        :id => id
      }
      id
    end

    alias :instance_on :add_instance_listener

    def remove_listener_from_instance(id_or_type)
      if id_or_type.class == Fixnum
        __instance_events.delete_if do |e|
          e[:id] == id_or_type
        end
      elsif [String, Symbol].include? id_or_type.class
        __instance_events.delete_if do |e|
          e[:type] == id_or_type.to_sym
        end
      end
    end

    def instance_emit(instance, type, *data)
      type = type.to_sym
      __instance_events.each do |e|
        case e[:type]
        when type
          listener = e[:listener]
          e[:type] = nil if e[:params][:once]
          instance.instance_exec(*data, &listener)
        when :*
          listener = e[:listener]
          e[:type] = nil if e[:params][:once]
          instance.instance_exec(type, *data, &listener)
        end
      end
      __instance_events.each do |e|
        remove_listener_from_instance e[:id] unless e[:type]
      end
    end

    def instance_once(type, &block)
      add_instance_listener type, {:once => true}, &block
    end
  end

end
