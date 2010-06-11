module Patchbay
  class Port < Integer
  end
  
  class Host < Addressable::URI
  end
  
  class Jack
    attr_accessor :host
    attr_accessor :port
    attr_accessor :protocol
    
    def validate!
      host.is_a?(Host) and port.is_a?(Port) and protocol.is_a?(Protocol)
    end
  end
  
  class In < Jack
  end
    
  class Out < Jack
    attr_accessor :returns
    
    def healthy?
      protocol.healthy?(host, port)
    end
  end
  
  class Patch
    attr_accessor :inputs
    attr_accessor :outputs
    attr_accessor :protocol
    attr_accessor :requirements
    
    def validate!
      bad_jacks.empty? and unmet_requirements.empty?
    end
    
    def bad_jacks
      (inputs + outputs).reject &method(:jack_matches_protocol)
    end
    
    def jack_matches_protocol(jack)
      jack.validate! and jack.protocol == protocol
    end
    
    def unmet_requirements
      requirements.reject &:validate!
    end
    
    def healthy_outputs
      outputs.select &:healthy?
    end
  end
  
  module Protocol
    class Base
      def healthy?(host, port)
        host.healthy? and unmet_requirements.empty?
      end
    end
    
    class Database < Base
    end
    
    class Service < Base
    end
    
    class Http < Service
    end
    
    class Log < Database
    end
    
    class Redis < Database
    end
    
    class Memcached < Database
    end
    
    class Mysql < Database
    end
  end
  
  class Requirement
    attr_reader :patch
    attr_reader :options
    
    def initialize(patch, options)
      @patch = patch
      @options = options
    end
    
    def call(jack)
      raise "Unimplemented Requirement#call implement in subclass."
    end
    
    def validate!
      false
    end
  end
  
  class Replication > Requirement
    def validate!
      number_of_replicants <= patch.healthy_outputs.count
    end
    
    def number_of_replicants
      options[:number_of_replicants] || 3
    end
  end
end

