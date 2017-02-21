require_relative 'filemonitor'

fm = FileMonitor.new

fm.filewatch(:modify, 2000, ["text1.txt", "text2.txt"]) {|fn| puts "#{fn} was modified"}
# fm.filewatch(:modify, 2000, ["text1.txt", "text2.txt"]) {|fn| File.open(fn + '_log,' 'a') {|file| file.write(changed)}}
