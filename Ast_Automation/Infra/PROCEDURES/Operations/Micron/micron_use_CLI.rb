load('Operations/Micron/MICRON_MODULE.rb')

mic = MICRON_MODULE.new

# get micron id
link = combo_box("Which link?","MIC_LSL","MIC_HSL")
micron_id = ask("Enter the Micron ID")
cli_cmd = ask_string("Enter the CLI command to send")


# need to upload in 21 character chunks
while true
  cli_cmd_len = cli_cmd.length  
  if cli_cmd_len <= 21
     res = mic.remote_cli(link, micron_id, 0, cli_cmd, "COMPLETED")
  else
     cli_str_arr = cli_cmd.split(' ') 
     iter_arr = cli_str_arr.take(cli_str_arr.length() - 1)
     iter_arr.each do |cli_str| 
       puts("sending #{cli_str}") 
       mic.remote_cli(link, micron_id, 0, cli_str, "CONTINUE")
     end
     res = mic.remote_cli(link, micron_id, 0, cli_str_arr.last, "COMPLETED")
  end
  puts(res)
  prompt(res)
     
  
  another_cmd = combo_box("Send another CLI command to #{micron_id}?","Yes","No")
  if another_cmd.eql? "No"
    break
  else
    cli_cmd = ask_string("Enter the CLI command to send")
  end
end

