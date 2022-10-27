load_utility('MICRON_FS_Upload.rb')
load('Operations\Tools\module_clogger.rb')
include CLogger

load('Operations/Micron/MICRON_MODULE.rb')


def run_micron_use_CLI(link, micron_id,cli_cmd)
   mic = MICRON_MODULE.new
   responses=[]

# need to upload in 21 character chunks

  cli_cmd_len = cli_cmd.length
  if cli_cmd_len <= 21
     res = mic.remote_cli(link, micron_id, 0, cli_cmd, "COMPLETED")
  else
     cli_str_arr = cli_cmd.split(' ')
     iter_arr = cli_str_arr.take(cli_str_arr.length()-1)
     puts iter_arr.inspect
     iter_arr.each do |cli_str|
       puts("sending #{cli_str}")
       if cli_str.length > 21
           # need to send in chunks
           cli_sub_arr = cli_str.split('')
           cli_sub_arr.each_slice(21) do |cli_chunk|
              cli_str_chunk = cli_chunk.join('')
              mic.remote_cli_body(link, micron_id, 0, cli_str_chunk)
           end
       else
          mic.remote_cli(link, micron_id, 0, cli_str, "CONTINUE")
       end
     end
     last_cli_str = cli_str_arr.last
     if last_cli_str.length > 21
        cli_sub_arr = last_cli_str.split('')
        cli_sub_arr.each_slice(21) do |cli_chunk|
           cli_str_chunk = cli_chunk.join('')
           mic.remote_cli_body(link, micron_id, 0, cli_str_chunk)
        end
        res = mic.remote_cli(link, micron_id, 0, '', "COMPLETED")
     else
        res = mic.remote_cli(link, micron_id, 0, last_cli_str, "COMPLETED")
     end
  end
  puts res
  #log_message(res)
  return res.inspect
end

