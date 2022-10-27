require 'json'

module FileTools

    def write_to_json(dictionary, path_json)
        create_directory_if_missing(path_json)
        file = nil
        if !File.exists?(path_json) then
            file = File.new(path_json,"w")
            file.write(dictionary.to_json)
        else
            file = File.open(path_json, "w")
            file.write(dictionary.to_json)
        end
        file.close
    end


    def read_json_file(path_to_json)
        if File.exists?(path_to_json) then
            return JSON.parse(File.read(path_to_json))
        else
            return nil
        end
    end


    def read_text_file_as_array(path_to_text_file)
        if File.exists?(path_to_text_file) then
            return File.readlines(path_to_text_file)
        else
            return nil
        end
    end

    def write_text_file_as_array(path_to_text_file, arr)
        puts "path new"
        puts path_to_text_file
        #puts path_to_text_file.gsub!("\\","/").strip
        puts path_to_text_file
        path_to_text_file.gsub!("\n","")
        puts path_to_text_file
        #File.open(path_to_text_file, "w") do |f|
         #   arr.each { |element| f.puts(element)}
          #end

          #path_to_text_file.gsub!("\\","/").strip
          file = nil
          if !File.exists?(path_to_text_file) then
              file = File.new(path_to_text_file,"w")
              arr.each {|element|
                file.puts(element)
                puts "write: #{element}"
              }
        
          else
              file = File.open(path_to_text_file, "w")
              arr.each {|element|
                file.puts(element)
                puts "write: #{element}"
              }
          end
          file.close
          wait 5
    end


    private
    def create_directory_if_missing(path)
        if path.rindex('\\') != nil
            path_only = path[0..path.rindex('\\')]
            if !Dir.exist?(path_only)
                Dir.mkdir(path_only)
            end
        end
    end

end
