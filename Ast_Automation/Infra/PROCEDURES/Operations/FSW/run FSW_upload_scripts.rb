load('Operations/FSW/FSW_FS_Upload.rb')

stack = vertical_message_box("Select a target stack:","YP", "YM")
script_dir = open_directory_dialog("./", "Select Directory containing FSW Scripts")

Dir.foreach(script_dir) do |script_file|
    if ['.','..'].include? script_file
        next
    end
    script_path = script_dir + '/' + script_file
    file_id = script_file.split(' ')[2].split('.')[0].to_i
    if file_id.between?(1537, 2048)
        board = "APC_#{stack}"
    elsif file_id.between?(2561, 3072)
        board = "FC_#{stack}"
    elsif file_id.between?(3585,4096)
        [1,2,3,4,5].each do |dpc_num|
            board = "DPC_#{dpc_num}"
            FSW_FS_Upload(1754, file_id, script_path, board)
        end
        break
    else
        puts("Invalid file id.")
        break
    end
    FSW_FS_Upload(1754, file_id, script_path, board)
end
