require 'shell'

module TestModule
  def commandHandler(command, options)
    sh = Shell.new

    # Shell.instance_methods.map { |t| puts t.to_s }

    # puts Shell.instance_methods
    # puts Shell.instance_methods.include? command

    sh.methods.map { |method| puts "#{method} defined by #{sh.method(method).owner}" }

    shell_methods = sh.methods.select! {
      |method| /Shell/.match(sh.method(method).owner.to_s).nil?
    }

    shell_method_names = shell_methods.map { |method| method.to_s }

    puts shell_methods.to_s
    puts shell_method_names.to_s

    # return

    # raise 'Invalid command' unless sh.respond_to? command
    raise 'Invalid command' unless shell_method_names.include? command

    sh.send(command, options)

    # case command
    # when 'rm'
    #   return sh.rm(options)
    # else
    #   puts 'Error: Invalid command'
    # end
  end

  def testModuleFunction
    while true do
      begin
        user_input = gets

        # regex = /\S+(\s+\S+)*/
        command_regex = /\S+/
        options_regex = /(\s+\S+)+/

        command = command_regex.match(user_input).to_s
        options = options_regex.match(user_input).to_s.strip

        # TODO: Remove
        # puts "Command: #{command}, is empty? #{command.empty?}"
        # puts "Options: #{options}, is empty? #{options.empty?}"

        # Use getoptlong somehow...

        # Start a new Process
        pid = Process.fork do
          begin
            # Ensure maximum safety level is set (sandbox)
            # $SAFE = 4

            # Enter switch statement to find determine shell command

            # Run shell command
            commandHandler command, options

            # return_value = %x(#{user_input})
          rescue RuntimeError => re
            puts "Error: #{re.to_s}"
          rescue SystemCallError
            puts 'System call error occured'
          end

          # puts "#{return_value}"
        end

        Process.wait(pid)

        # Return results in parent process (How does the parent get the results?)
      rescue Interrupt
        abort("\n")
      end


      # begin
      #   user_input = gets
      #
      #   # Parse input, verify contracts
      #
      #   sh = Shell.new # ...
      #
      #   pid = Process.fork do
      #     begin
      #       return_value = %x(#{user_input})
      #     rescue SystemCallError => e
      #       puts 'System call error occured: ', e.to_s
      #     end
      #
      #     puts "#{return_value}"
      #   end
      #
      #   Process.wait(pid)
      # rescue Interrupt
      #   abort("\n")
      # end
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


# sh = Shell.new

# sh.transact do
#   mkdir "test_dir"
# end

# puts Shell.instance_methods.map {
#   |thing| puts thing.to_s unless thing.to_s.empty?
# }

# puts sh.respond_to? :rm
# puts Shell.instance_method(:rm).arity
# puts Shell.instance_method(:rm).parameters
