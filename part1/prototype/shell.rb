class Shell
    def run
        while (true)
            prog = get_command
            child_id = fork_program(prog)
            if (child_id)
                wait_on(child_id)
                report_results
            else
                change_job(prog)
            end
        end
    end

    def get_command
    end

    def fork_program
    end

    def wait_on
    end

    def report_results
    end

    def change_job
    end

end
