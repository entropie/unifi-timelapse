module UTL

  class ProcessDay < CommandComplex

    class ProcessDayArguments < UTL::Arguments
      required    :day

      def day=(obj)
        UTL.date_from_string(obj).to_s
      end
    end

    def initialize(opts)
      @arguments = ProcessDayArguments.new(opts)
    end


    def remote_path
      @remote_path ||= File.join(all_arguments[:server_workdir], UTL.date_to_path(all_arguments[:day]))
    end

    def local_path
      @local_path ||= File.join(all_arguments[:workdir], "source", UTL.date_to_path(all_arguments[:day]))
    end

    def run
      # get remote filelist

      ls = Command.run(RListUBV, all_arguments, :path => File.join(remote_path, "/*"))
      ls.run

      if ls.result.empty?
        info("no result from remote")
        return false
      end


      remux_prepare = Command.run(RPrepareRemux, all_arguments, :path => remote_path)
      remux_prepare.run

      # # get remote filelist (again)
      ls = Command.run(RListUBV, all_arguments, :path => File.join(remote_path, "/*"))
      ls.run

      copyfiles = Command.run(RCopyList, all_arguments, :fileslist => ls.result)
      copyfiles.run

      makeday = Command.run(LMakeDay, all_arguments, {})
      makeday.run

      merge = Command.run(LMerge, all_arguments, {})
      merge.run

      cleanup = Command.run(LCleanup, all_arguments, :local_path => local_path)
      cleanup.run
    end

  end

end
