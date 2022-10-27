module TestSuiteTools
    def load_test_files(subsystem_folder, file_filter)
        # This finds all files in provided subsytem_folder that match the file_filter, and loads them
        rbfiles = File.join(subsystem_folder, '**', file_filter)
        puts rbfiles
        Dir[rbfiles].sort.each { |file|
            load file
        }
    end

    def get_ait_path
        # Returns the PROCEDURES/AIT folder, discovered as a relative path from this file.
        procedures_folder = File.expand_path("..", File.expand_path("..", __dir__))
        ait_folder = File.join(procedures_folder, "AIT")

        return ait_folder
    end


    def add_tests(subsystem_cosmos_test_object, subsystem, pattern_string)
        subsystem_folder = File.join(self.get_ait_path, subsystem)

        self.load_test_files(subsystem_folder, pattern_string)

        subsystem_cosmos_test_object.descendants.each { |desc|
            add_test(desc)
        }
    end

end
