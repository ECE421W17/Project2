working_directory = ARGV[0]
command = ARGV[1]
arguments = ARGV[2]

Dir.chdir(working_directory) {
  if command == 'cd'
    system("#{command} #{arguments}")
  else
    exec("#{command} #{arguments}")
  end
}
