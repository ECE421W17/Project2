# puts "Argument (s): #{ARGV[0]}, #{ARGV[1]}"

command = ARGV[0]
arguments = ARGV[1]
working_directory = ARGV[2]

# case command
# when 'cd'
#   # sh = Shell.new
#   # sh.cd(arguments)
#   # Kernel.cd(arguments)
#   # Dir.chdir(arguments)
# else
#   exec("#{command} #{arguments}")
# end

# puts "Running command: cd #{working_directory}; #{command} #{arguments}"

exec("cd #{working_directory}; #{command} #{arguments}")
# system("#{command} #{arguments}")
