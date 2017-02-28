require 'shell'
require 'fileutils'

class BashShell
  def initialize
    @working_directory_path = FileUtils.getwd
    @working_directory_path.untaint # TODO: ???

    # PRIORITY: Properly vet this path in pre/post conditions
    @shell_command_handler_script_path =
      File.expand_path("./shell_command_handler.rb")
    @shell_command_handler_script_path.untaint # TODO: ???
  end

  def validate_user_input(command, arguments)
    # PRIORITY: Properly vet the inputs; maybe in pre/post conditions
    command.untaint
    arguments.untaint
  end

  def upate_working_directory_path(arguments)
    # TODO: See if using Dir instead will work
    # => There's a chdir method, and a path method
    # => Maybe you could store a Dir object instead of the path
    res = %x(cd #{@working_directory_path}; cd #{arguments}; pwd)
    res = res.delete("\n")

    @working_directory_path = res

    # TODO: Actually do some sort of validation
    @working_directory_path.untaint
  end

  def run
    while true do
      begin
        print "#{@working_directory_path}$ "
        user_input = gets

        # TODO: Add support for pipes also?
        # regex = /\S+(\s+\S+)*/
        command_regex = /\S+/
        arguments_regex = /(\s+\S+)+/

        command = command_regex.match(user_input).to_s
        arguments = arguments_regex.match(user_input).to_s.strip

        validate_user_input(command, arguments)

        # Use getoptlong somehow... ?

        # Start a new Process
        pid = Process.fork do
          begin
            # Prohibit core dumps
            Process.setrlimit(Process::RLIMIT_CORE, 0, 0)

            # Ensure adequate safety level is set
            # Note: If the 'load' method becomes uneeded, use level 2 instead
            $SAFE = 1

            # Load external source to prohibit the possibility of external variables interacting with the namespace of the current process
            ARGV[0] = command
            ARGV[1] = arguments
            ARGV[2] = @working_directory_path
            load(@shell_command_handler_script_path, true)

            # Run shell command
            # output = command_handler command, arguments
            #
            # puts output.to_s

          # TODO: Figure out how to catch/handle Errno exceptions...
          rescue RuntimeError => re
            puts "Error: #{re.to_s}"

          # TODO: Don't log error specifics
          # PRIORITY: Why aren't exceptions being thrown anymore?
          # => Seems to be that adding the "cd #{}; to the path in the exec call within the script prohibits the throwing of exceptions..."
          rescue SystemCallError => sce
            puts "System call error occured: #{sce.to_s}"

            # Workaround:
            # => If a 'cd' command fails to execute, do not update the
            # => internal working_directory_path
            arguments = '' unless command != 'cd'
          end
        end

        Process.wait(pid)

        # Update the internal working_directory_path
        if command == 'cd' && !arguments.empty?
          upate_working_directory_path(arguments)
        end
      rescue Interrupt
        abort("\n")
      end
    end
  end
end

bs = BashShell.new
bs.run
