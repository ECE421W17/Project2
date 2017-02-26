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
        end

        exit if fork # run the notifier in a background process
        @notifier.run
    end

end

