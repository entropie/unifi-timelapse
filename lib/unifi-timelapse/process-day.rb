module UTL
  class ProcessDay

    class ProcessDayArguments < UTL::Arguments
      required    :day

      def day=(obj)
        UTL.date_from_string(obj).to_s
      end
    end

    attr_reader :arguments

    def initialize(opts)
      @arguments = ProcessDayArguments.new(opts)
    end

    def run
      all_arguments = Arguments.combine_arguments(@arguments)

      rpath = File.join(all_arguments[:server_workdir], UTL.date_to_path(all_arguments[:day]))
      lpath = File.join(all_arguments[:workdir], "source", UTL.date_to_path(all_arguments[:day]))

      mock = true
      
      # get remote filelist
      ls = RCMD.run(RListUBV, all_arguments, :path => File.join(rpath, "/*"))
      ls.run

      remux_prepare = RCMD.run(RPrepareRemux, all_arguments, :path => rpath)
      remux_prepare.run

      # # get remote filelist (again)
      ls = RCMD.run(RListUBV, all_arguments, :path => File.join(rpath, "/*"))
      ls.run


      copyfiles = RCMD.run(RCopyList, all_arguments, :fileslist => ls.result)
      copyfiles.run

      makeday = RCMD.run(LMakeDay, all_arguments, {})
      makeday.run

      cleanup = RCMD.run(LCleanup, all_arguments, :local_path => lpath)
      cleanup.run
    end

  end

end
