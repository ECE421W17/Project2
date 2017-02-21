class FileMonitor

    def initialize
        @filenames = { :creation => [],
                       :alter => [],
                       :destroy => [] }
        @duration = { :creation => 0,
                   :alter => 0,
                   :destroy => 0 }
    end

    def filewatch(type, duration, filenames)
        if !@filenames.has_key?(type) or !@duration.has_key?(type)
            raise "Some exception"
        end

        @filenames[type] = filenames
        @duration[type] = duration
    end

end

