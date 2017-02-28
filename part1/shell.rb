require 'digest'
require 'fileutils'
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

        command, arguments = get_user_command

        # Start a new Process
        pid = Process.fork do
          begin
            _configure_user_command_process

            _process_user_command(command, arguments)

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

        # Can you use Errno instead to check the return status of the last exec
        # call? Then use that to decide whether or not you should update the
        # internal path?
        # Update the internal working_directory_path
        if command == 'cd'
          path = _get_cd_command_path(arguments)
          _upate_working_directory_path(arguments) unless path.empty?
        end
      rescue Interrupt
        abort("\n")
      end
    end
  end

  def _get_cd_command_path(command_arguments)
    # l_flags_regex = /-L(\s)+(\S)+/
    l_flags_regex = /-L/
    # p_flags_regex = /-P(\s)+(\S)+/
    p_flags_regex = /-P/
    # e_flags_regex = /-e(\s)+(\S)+/
    e_flags_regex = /-e/
    # at_flags_regex = /-@(\s)+(\S)+/
    at_flags_regex = /-@/

    flags_regex = /-(\S)+/

    l_flags = l_flags_regex.match(command_arguments)
    p_flags = p_flags_regex.match(command_arguments)
    e_flags = e_flags_regex.match(command_arguments)
    at_flags = at_flags_regex.match(command_arguments)

    flags = flags_regex.match(command_arguments)

    puts "L flags: #{l_flags}"
    puts "P flags: #{p_flags}"
    puts "e flags: #{e_flags}"
    puts "@ flags: #{at_flags}"

    puts flags

    path = command_arguments
    # path.slice! l_flags unless l_flags.nil?
    path.slice!(flags.to_s) unless flags.nil?

    return path
  end

  def _verify_initialize_pre_conditions
  end

  def _verify_initialize_post_conditions
    # TODO: Add some regex verification?

    assert(File.exist?(@shell_command_handler_script_path),
      "The given shell command handler file path is invalid")
    assert(Dir.exist?(@working_directory_path),
      "The working directory of the executable is invalid")

    # Verify that the hash of the script matches that of the "released" file
    hash = Digest::SHA256.file @shell_command_handler_script_path
    assert(hash.hexdigest ==
      "37c4bfc99112b26affffe0a58ec5bde167e9e31ae574bae17f0aaca3d6fd0efe",
        "The external shell command handler script has an invalid hash")

    @shell_command_handler_script_path.untaint
    @working_directory_path.untaint
  end

  def _verify_get_user_command_pre_conditions
  end

  def _verify_get_user_command_post_conditions(command, arguments)
    # TODO: Actually verify

    command.untaint
    arguments.untaint
  end

  def get_user_command
    _verify_get_user_command_pre_conditions

    user_input = gets

    command_regex = /\S+/
    arguments_regex = /(\s+\S+)+/

    command = command_regex.match(user_input).to_s
    arguments = arguments_regex.match(user_input).to_s.strip

    _verify_get_user_command_post_conditions(command, arguments)

    return command, arguments
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

    # Load external source to prohibit the possibility of external variables
    # interacting with the namespace of the current process
    ARGV[0] = @working_directory_path
    ARGV[1] = command
    ARGV[2] = arguments
    load(@shell_command_handler_script_path, true)

    _verify_process_user_command_post_conditions
  end

  def _update_working_directory_path_pre_conditions(arguments)
    assert(!arguments.tainted?, "User command arguments are tainted")
    assert(
      !@working_directory_path.tainted?, "Working directory path is tainted")
    assert(Dir.exist?(@working_directory_path),
      "The working directory of the executable is invalid")
  end

  def _update_working_directory_path_post_conditions
    # TODO: More verfication?

    assert(Dir.exist?(@working_directory_path),
      "The working directory of the executable is invalid")
    @working_directory_path.untaint
  end

  def _upate_working_directory_path(arguments)
    _update_working_directory_path_pre_conditions(arguments)

    # TODO: See if using Dir instead will work
    # => There's a chdir method, and a path method
    # => Maybe you could store a Dir object instead of the path
    res = %x(cd #{@working_directory_path}; cd #{arguments}; pwd)
    res = res.delete("\n")

    @working_directory_path = res

    _update_working_directory_path_post_conditions
  end
end

bs = BashShell.new
bs.run
