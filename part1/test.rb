require 'shell'

module TestModule
  def testModuleFunction
    while true do
      begin
        user_input = gets

        # regex = /\S+(\s+\S+)*/
        # regex = /Y/
        # regex = /\S+/

        command_regex = /\S+/
        options_regex = /(\s+\S+)+/

        command = command_regex.match(user_input).to_s
        options = options_regex.match(user_input).to_s.strip

        puts "Command: #{command}, is empty? #{command.empty?}"
        puts "Options: #{options}, is empty? #{options.empty?}"

        # Use getoptlong somehow...

        # Start a new Process

        # Ensure maximum safety level is set (sandbox)

        # Enter switch statement to find determine shell command

        # Run shell command

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

puts 'In program'

test = TestClass.new

test.testClassFunction

# TestModule::testModuleFunction



# sh.transact do
#   mkdir "test_dir"
# end

# puts Shell.instance_methods.map {
#   |thing| puts thing.to_s unless thing.to_s.empty?
# }
