load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_FWUPD.rb')
load('Operations/FSW/FSW_CSP.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS_Continue_Upload.rb')



class RF_MANUAL_UPLOAD_CONTINOUS < ASTCOSMOSTestFSW
  def initialize(target = "BW3")
    super()
  end

  def setup
    @board = combo_box("Select board for image upload", "APC_YP", "APC_YM")
    @file_id = 4108

    if @board.include?("DPC")
      @stack = combo_box("Select side", "YP", "YM")
    end
  end

  def test_RF_Continuous_Upload

  image_directory =  __dir__ + '\\' + "image_bins\\" + "apcBL2_Test.bin" # It doesn't mmatter what we upload, not installing the image. 

   FSW_FS_Upload_Slim(186, @file_id, image_directory, @board, aspect="CRC", "TEST")
   FSW_FS_Continue_Upload_Slim(186, @file_id,  image_directory, @board, aspect="CRC", starting_entry=1)
  end
end
  

