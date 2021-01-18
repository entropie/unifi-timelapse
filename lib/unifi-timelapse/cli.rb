require 'optparse'


module UTL
  class Cli
    def self.parse(opthash)
      opthash.parse
    end

    def self.options(&blk)
      cli = Cli.new
      cli.option_parser = OptionParser.new(blk)
      cli.option_parser.instance_eval(&blk)
      yield cli.option_parser, cli
      cli
    end

    attr_reader :opts
    attr_accessor :option_parser

    def initialize
      @opts = {}
    end

    def []=(key, v)
      opts[key.to_sym] = v
    end

    def parse
      option_parser.parse!
    end

    def process_day
      dl = UTL::ProcessDay.new(@opts)
      dl.run
    end

    def run
    end
  end

end
