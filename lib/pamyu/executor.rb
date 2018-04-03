require "open3"

module Pamyu
  class Executor
    def initialize(command, out, err)
      @command = command
      @out = out
      @err = err
    end

    def execute
      status = nil
      Open3.popen3(*@command) do |stdin, stdout, stderr, wait_thr|
        iomap = { stdout => @out, stderr => @err }
        stdin.write($stdin.read) unless $stdin.isatty
        stdin.close_write
        begin
          loop do
            IO.select([stdout, stderr]).flatten.compact.each do |io|
              io.each do |line|
                iomap[io].write line
              end
            end
            break if stdout.eof? && stderr.eof?
          end
        rescue EOFError
        end
        status = wait_thr.value
      end
      status
    end
  end
end
