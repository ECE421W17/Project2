require 'rb-inotify'
require 'set'

class FileMonitor

    def millis_to_sec(duration)
        duration/1000.0
    end

    def initialize
        @notifier = INotify::Notifier.new
        @file_watch_types = Set.new [:modify]
        @directory_watch_types = Set.new [:create, :delete]
    end

    def filewatch(type, duration, filenames, &action)
        if @file_watch_types.include?(type)
            filenames.each do |fn|
                @notifier.watch(fn, type) do |event|
                    sleep millis_to_sec(duration)
                    action.call(fn)
                    @notifier.close
                end
            end
        elsif @directory_watch_types.include?(type)
            filenames.each do |fn|
                @notifier.watch(".", type) do |event|
                    if event.name == fn
                        sleep millis_to_sec(duration)
                        action.call(event.name)
                        @notifier.close
                    end
                end
            end
        else
            raise ArgumentError, "The file watch type needs to be one of the symbols #{(@file_watch_types + @directory_watch_types).to_a}"
        end

        exit if fork # run the notifier in a background process

        Process.setrlimit(:CORE, 0, 0) # don't dump core for security reasons
        @notifier.run
    end

end

