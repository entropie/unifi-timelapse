# coding: utf-8
module UTL

  class RCMD
    attr_accessor :opts, :cmdhsh
    attr_reader   :result

    
    def self.run(what, opts, cmdhsh)
      info("RCMD:#{what} initialize")
      cmd = what.new(cmdhsh)
      cmd.opts = opts
      return cmd
    end

    def initialize(cmdhsh)
      @cmdhsh = cmdhsh
    end

    def cmdprefix
      "ssh"
    end

    def sshopts
      "%s %s@%s" % [opts[:sshopts], opts[:sshuser], opts[:address]]
    end

    def command
      "%s" % [cmdprefix]
    end

    def validate!
      self.class.required_arguments.each do |ra|
        raise "#{self.class}:#{ra} not set " unless @cmdhsh.include?(ra)
      end
    end

    def execute(what)
      $stdout.sync = false
      print "     running: #{what}"
      ret = `#{what}`
      print " ok\n"
      $stdout.sync = true
      ret
    end

    def run
      validate!
      @result = ""
      @result = execute(command)
      @result
    end

    def self.required(args)
      required_arguments.push(*args)
    end

    def self.required_arguments
      @required_arguments ||= []
      @required_arguments
    end

    def dev_null_redirection
      "2>&1 /dev/null"
    end
    
    def ffmpeg_no_output
      "-hide_banner -loglevel panic"
    end
  end


  class LMakeDay < RCMD

    def local_path
      File.join(opts[:workdir], "source", UTL.date_to_path(opts[:day]))
    end

    def media_files
      Dir.glob("%s/%s" % [local_path, "*.mp4"])
    end

    def make_concat_str
      media_files.sort_by{ |mf|
        mf.split("_").last
      }.select{|mf|
        File.basename(mf) =~ /^speedy/
      }.map{|mf|
        "file '%s'" % [mf]
      }.join("\n")
    end

    def remux_media_files!
      execute "cd '%s' && remux %s %s" % [local_path, "*.ubv", dev_null_redirection]
    end

    def speedup_media_files!
      speedup = opts[:speedup]
      media_files.each do |mf|
        basename = File.basename(mf)
        mpath, mfile = [File.dirname(mf), basename]
        new_filename = File.join(mpath, "speedy-" + mfile)
        execute "ffmpeg -y -i #{mf} -vf 'setpts=#{speedup}*PTS' -an '%s' %s" % [new_filename, ffmpeg_no_output]
      end
    end

    def concat_speedup_files!
      File.open(File.join(local_path, "concat.txt"), "w+") do |fp|
        fp.puts(make_concat_str)
      end
      
      Dir.chdir(local_path) do 
        execute "ffmpeg -y -f concat -safe 0 -i concat.txt -c copy %s.mp4 %s" % [ File.join(opts[:workdir], opts[:day]), ffmpeg_no_output ]
      end
    end
    
    def run
      remux_media_files!
      speedup_media_files!
      concat_speedup_files!
    end
  end

  class LCleanup < RCMD
    def h
      "deletes workdir/source/YYYY/DD/MM temporary files "
    end

    def run
      execute "rm -rf '%s'" % [cmdhsh[:local_path]]
    end
  end

  class LMerge < RCMD
    def h
      "merge single parts to complete file "
    end

    def generate_concat_file
      file = File.join(opts[:workdir], "concat.txt")
      file_contents = Dir.glob("%s/*-*-*.mp4" % opts[:workdir]).
        sort_by{|mf| File.basename(mf) }.
        map do |media_file|
        "file '%s'" % media_file
      end.join("\n")
      File.open(file, "w+"){|fp| fp.puts(file_contents)}
      file
    end

    def merge_files(filename)
      execute "ffmpeg -y -f concat -safe 0 -i #{filename} -c copy %s %s" % [ File.join(opts[:workdir], "merged.mp4"), ffmpeg_no_output ]
    end
    
    def run
      merge_files(generate_concat_file)
    end
  end
  
  class RLS < RCMD
    required :path
    
    def h
      "run ls on remote"
    end

    def command
      "%s %s -- ls '%s'" % [super, sshopts, cmdhsh[:path]]
    end

    def result
      @result.split("\n")
    end
  end

  class RListUBV < RLS
    required :path
    def h
      "run ls on remote adding some filtering"
    end

    def command
      "%s %s -- ls '%s'" % [cmdprefix, sshopts, cmdhsh[:path] + "#{opts[:camera]}_0_rotating_*"]
    end
  end

  class RPrepareRemux < RCMD
    required :path

    def h
      "runs remux:prepare.sh on (path)"
    end

    def command
      "%s %s 'cd %s && %s %s'" % [super, sshopts, cmdhsh[:path], '/.$HOME/prepare.sh', "#{opts[:camera]}_0_rotating_*.ubv"]
      
    end
  end

  class RCopyList < RLS
    required :fileslist

    def h
      "copies remote filelist to config[workdir]/source"
    end

    def cmdprefix
      "scp"
    end

    def local_target_dir
      File.join(opts[:workdir], "source")
    end

    def command
      cmds = []

      cmdhsh[:fileslist].each do |remote_file|
        locale_file_path = File.join(local_target_dir, remote_file.gsub(opts[:server_workdir], ""))
        c = "%s %s:%s %s" % [cmdprefix, sshopts, remote_file, locale_file_path]
        cmds << c
      end
      cmds
    end

    def run
      command.each do |cmd_line|
        FileUtils.mkdir_p(File.dirname(cmd_line.split(" ").last))
        execute(cmd_line)
      end
    end
  end
  
end
