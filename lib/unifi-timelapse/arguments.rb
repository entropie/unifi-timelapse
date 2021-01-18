module UTL
  class Arguments

    def self.combine_arguments(args)
      args.validate
      Arguments.new(C.config).merge(args)
    end
    
    def self.required_arguments
      @required_arguments ||= []
      @required_arguments
    end

    def self.optional_arguments
      @optional_arguments ||= []
      @optional_arguments
    end


    def self.required(*symbols)
      required_arguments.push(*symbols)
    end

    def self.optional(*symbols)
      optional_arguments.push(*symbols)
    end

    def merge(ohash)
      self.class.new(@arguments.merge(ohash.arguments))
    end

    def set_argument(key, v)
      @arguments[key] = v
      debug("transform_argument: manually setting key '#{key}'='#{v}'")
    end

    def transform_argument(akey, avalue)
      if self.respond_to?("#{akey}=")
        newval = send("#{akey}=", avalue)
        if newval
          @arguments[akey] = newval
        else
          debug("transform_argument: deleting key '#{akey}' because #{self.class}.#{akey}='#{avalue}' returns no value")
          @arguments.delete(akey)
        end
      end
    end

    attr_reader :arguments

    def initialize(opts)
      @arguments = opts

      @arguments.dup.each_pair do |argkey, argvalue|
        self.transform_argument(argkey, argvalue)
      end
    end

    def [](arg)
      @arguments[arg]
    end

    def arguments_to_str(arghsh)
      ret = ""
      arghsh.each do |argk, argv|
        ret << "--#{argk}='#{argv}' "
      end
      ret
    end

    def validate
      self.class.required_arguments.each do |ra|
        required_argument_value = self[ra]
        unless required_argument_value
          debug "argument validation: #{self.class}: #{ra} not set"
        end
      end
      # self.class.optional_arguments
    end

    def to_s
      ret = ""
      ret << arguments_to_str(@arguments)
      ret
    end
  end

end
