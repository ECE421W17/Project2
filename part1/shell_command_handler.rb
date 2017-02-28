working_directory = ARGV[0]
command = ARGV[1]
arguments = ARGV[2]

Dir.chdir(working_directory) {
  if command == 'cd'
    unless arguments.empty?
      system(command, arguments)
    else
      system(command)
    end
  else
    unless arguments.empty?
      exec(command, arguments)
    else
      exec(command)
    end
  end
}
