require 'shell'

module TestModule
  def command_handler(command, arguments)
    sh = Shell.new

    # puts sh.method('mkdir').owner.to_s

    # return

    sh.debug = false
    sh.verbose = false
    # puts "Verbose? #{sh.verbose?}"

    # raise 'Invalid command' unless sh.respond_to? command

    # Enter switch statement to find determine shell command
    case command
    when 'mkdir'
      sh.mkdir(arguments)
    when 'rmdir'
      sh.rmdir(arguments)
    when 'pwd'
      sh.pwd
    when 'echo'
      sh.echo(arguments)
    else
      raise 'Invalid command'
    end

    # TODO: Restrict commands to valid operations
    # if sh.method(command).arity == 0 || arguments.empty?
    #   sh.send(command)
    # else
    #   sh.send(command, arguments)
    # end
  end

  def testModuleFunction
    while true do
      begin
        user_input = gets

        # TODO: Add support for pipes also
        # regex = /\S+(\s+\S+)*/
        command_regex = /\S+/
        arguments_regex = /(\s+\S+)+/

        command = command_regex.match(user_input).to_s
        arguments = arguments_regex.match(user_input).to_s.strip

        # Use getoptlong somehow...

        # Start a new Process
        pid = Process.fork do
          begin
            # TODO: Ensure maximum safety level is set (sandbox)
            # $SAFE = 4

            # Run shell command
            output = command_handler command, arguments

            puts output.to_s unless output.instance_of? Shell::Void
          rescue RuntimeError => re
            puts "Error: #{re.to_s}"

          # TODO: Don't log error specifics
          rescue SystemCallError => sce
            puts "System call error occured: #{sce.to_s}"
          end
        end

        Process.wait(pid)

        # TODO: Return results in parent process (How does the parent get the results?)
      rescue Interrupt
        abort("\n")
      end
    end
  end
end

class TestClass
  include TestModule

  def testClassFunction
    testModuleFunction
  end
end

test = TestClass.new
test.testClassFunction
