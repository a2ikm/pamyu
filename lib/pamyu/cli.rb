require "optparse"
require_relative "executor"

module Pamyu
  class CLI
    def initialize(argv = [])
      @argv = argv.dup
    end

    def execute
      command, options = parse_argv
      out, err = open_files(options)
      Executor.new(command, out, err).execute
    end

    def parse_argv
      options = {}
      op = new_option_parser(options)
      op.permute!(@argv)

      abort op.help if @argv.empty?

      [@argv, options]
    end

    def new_option_parser(options = {})
      OptionParser.new do |op|
        op.on "-o", "--out FILE" do |file|
          options[:out] = file
        end
        op.on "-e", "--err FILE" do |file|
          options[:err] = file
        end
      end
    end

    COPY = "-"

    def open_files(options)
      op_out = options.delete(:out)
      op_err = options.delete(:err)

      if op_out && op_err
        if op_out == op_err
          out = err = open(op_out)
        elsif op_err == COPY
          out = err = open(op_out)
        elsif op_out == COPY
          out = err = open(op_err)
        else
          out = open(op_out)
          err = open(op_err)
        end
      elsif op_out
        out = open(op_out)
      elsif op_err
        err = open(op_err)
      end

      [out, err]
    end

    def open(file)
      File.open(file, "wb")
    end
  end
end
