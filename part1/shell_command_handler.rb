working_directory = ARGV[0]
command = ARGV[1]
arguments = ARGV[2]

Dir.chdir(working_directory) {
  command_string = "#{command} #{arguments}"
  if command == 'cd'
    system(command_string)
  else
    exec(command_string)
  end
}
