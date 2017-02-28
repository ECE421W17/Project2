require 'shell'
require 'fileutils'

class BashShell
  def initialize
    puts 'In init...'

    @working_directory_path = FileUtils.getwd
    @working_directory_path.untaint # TODO: ???
  end

  def command_handler(command, arguments)
    puts "Command tainted? #{command.tainted?}, arguments tainted? #{arguments.tainted?}"

    exec("#{command} #{arguments}")
  end

  def validate_user_input(command, arguments)
    # TODO: Properly vet the inputs
    command.untaint
    arguments.untaint
  end

  def upate_working_directory_path(arguments)
    res = %x(cd #{@working_directory_path}; cd #{arguments}; pwd)
    res = res.delete("\n")

    @working_directory_path = res
    @working_directory_path.untaint

    # TODO: Remove
    # puts "Updated working directory: #{@working_directory_path}"

    return

    return if arguments.empty?

    # unless /.\/S*/.match(arguments).nil?
    #   puts 'Relative path match'
    # end

    # TODO: Make this more robust
    absolute_path_regex = /\/(\S*)/
    test_reg = /(\/)|(\/S+(\/S+)*(\/)?)/

    test = test_reg.match(arguments)
    unless test.nil?
      puts 'MATCHED!'
    else
      puts 'DID NOT MATCH :('
    end

    absolute_path = absolute_path_regex.match(arguments)
    unless absolute_path.nil?
      # Process relative path
      puts 'Processing absolute path...'
    else
      puts 'Processing relative path...'

      unless /.\/S*/.match(arguments).nil?
        puts 'Relative path match'
      end

      # relative_path = relative_path_regex.match(arguments)
      # unless relative_path.nil?
      #   puts 'Processing relative path...'
      # end

      # Invalid path...
      puts 'Path invalid...'
    end

    @working_directory_path
  end

  def run
    # TODO: Clean this up; put it in a method or something
    filename = File.expand_path("./file2.rb")
    filename.untaint

    while true do
      begin
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
            load(filename, true)

            # Run shell command
            # output = command_handler command, arguments
            #
            # puts output.to_s
          rescue RuntimeError => re
            puts "Error: #{re.to_s}"

          # TODO: Don't log error specifics
          rescue SystemCallError => sce
            puts "System call error occured: #{sce.to_s}"

            arguments = '' unless command != 'cd'
          end
        end

        Process.wait(pid)

        if command == 'cd' && !arguments.empty?
          # @working_directory_path = arguments
          upate_working_directory_path(arguments)
        end

        # TODO: Return results in parent process (How does the parent get the results?)
      rescue Interrupt
        abort("\n")
      end
    end
  end
end

bs = BashShell.new
bs.run
