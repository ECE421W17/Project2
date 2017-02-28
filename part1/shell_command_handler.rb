# TODO: Try to get user input in here instead of
working_directory = ARGV[0]
command = ARGV[1]
arguments = ARGV[2]

Dir.chdir(working_directory) {
  if command == 'cd'
    # path = File.expand_path(arguments)
    # path.untaint

    # TODO: Find a better way?
    # => Executing 'cd ...' in any way (%x(cd ...), `cd ...`, exec("cd ..."))
    # => results in an exception from the shell.
    # => Note: Converting relative paths to fully expanded absolute paths
    # => before calling "cd #{path}" in any of the above ways yielded the same
    # => results
    system("#{command} #{arguments}")
  else
    exec("#{command} #{arguments}")
  end
}
