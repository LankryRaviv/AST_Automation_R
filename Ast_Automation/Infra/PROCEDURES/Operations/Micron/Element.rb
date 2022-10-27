class Element
    def initialize(id,forward)
      @micron_id = id
      @target = forward
    end

    def get_micron_id()
        return @micron_id
    end
    
    def get_target()
        return @target
    end
end