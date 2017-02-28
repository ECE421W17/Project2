require 'fileutils'
# require 'shell' # TODO: Remove?
require 'test/unit/assertions'

include Test::Unit::Assertions

class BashShell
  def initialize
    _verify_initialize_pre_conditions

    @working_directory_path = FileUtils.getwd
    @shell_command_handler_script_path =
      File.expand_path("./shell_command_handler.rb")

    _verify_initialize_post_conditions
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

        _validate_user_input(command, arguments)

        # Use getoptlong somehow... ?

        # Start a new Process
        pid = Process.fork do
          begin
            _configure_user_command_process

            _process_user_command(command, arguments)
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
          _upate_working_directory_path(arguments)
        end
      rescue Interrupt
        abort("\n")
      end
    end
  end

  def _verify_initialize_pre_conditions
  end

  def _verify_initialize_post_conditions
    # TODO: Add some regex verification?

    assert(File.exist?(@shell_command_handler_script_path),
      "The given shell command handler file path is invalid")
    assert(Dir.exist?(@working_directory_path),
      "The working directory of the executable is invalid")

    @shell_command_handler_script_path.untaint
    @working_directory_path.untaint
  end

  def _configure_user_command_process
    # Prohibit core dumps
    Process.setrlimit(Process::RLIMIT_CORE, 0, 0)

    # Ensure adequate safety level is set
    $SAFE = 1
  end

  def _verify_process_user_command_pre_conditions
    assert(Process.getrlimit(Process::RLIMIT_CORE)[0] == 0,
      "Core resource soft limit is non zero (#{Process::RLIMIT_CORE[0]})")
    assert(Process.getrlimit(Process::RLIMIT_CORE)[1] == 0,
      "Core resource hard limit is non zero (#{Process::RLIMIT_CORE[1]})")
    assert($SAFE == 1, "Inadequate $SAFE level (#{$SAFE})")
    assert(
      !@working_directory_path.tainted?, "Working directory path is tainted")
    assert(!@shell_command_handler_script_path.tainted?,
      "Shell command handler script path is tainted")
  end

  def _verify_process_user_command_post_conditions
    assert(Process.getrlimit(Process::RLIMIT_CORE)[0] == 0,
      "Core resource soft limit is non zero (#{Process::RLIMIT_CORE[0]})")
    assert(Process.getrlimit(Process::RLIMIT_CORE)[1] == 0,
      "Core resource hard limit is non zero (#{Process::RLIMIT_CORE[1]})")
    assert($SAFE == 1, "Inadequate $SAFE level (#{$SAFE})")
    assert(
      !@working_directory_path.tainted?, "Working directory path is tainted")
    assert(!@shell_command_handler_script_path.tainted?,
      "Shell command handler script path is tainted")
  end

  def _process_user_command(command, arguments)
    _verify_process_user_command_pre_conditions

    # Load external source to prohibit the possibility of external variables interacting with the namespace of the current process
    ARGV[0] = @working_directory_path
    ARGV[1] = command
    ARGV[2] = arguments
    load(@shell_command_handler_script_path, true)

    # Run shell command
    # output = command_handler command, arguments
    #
    # puts output.to_s

    # TODO: Figure out how to catch/handle Errno exceptions...

    _verify_process_user_command_post_conditions
  end

  def _validate_user_input(command, arguments)
    # PRIORITY: Properly vet the inputs; maybe in pre/post conditions
    command.untaint
    arguments.untaint
  end

  def _update_working_directory_path_pre_conditions
    # Check that path is valid
  end

  def _update_working_directory_path_post_conditions
    # Check that path is valid
  end

  def _upate_working_directory_path(arguments)
    _update_working_directory_path_pre_conditions

    # TODO: See if using Dir instead will work
    # => There's a chdir method, and a path method
    # => Maybe you could store a Dir object instead of the path
    res = %x(cd #{@working_directory_path}; cd #{arguments}; pwd)
    res = res.delete("\n")

    @working_directory_path = res

    # TODO: Actually do some sort of validation
    # @working_directory_path.untaint

    _update_working_directory_path_post_conditions
  end
end

bs = BashShell.new
bs.run
