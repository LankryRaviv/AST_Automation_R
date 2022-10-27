require 'roo'

class PwrGoodIndicatorsExcelReader

    def initialize(power_mode)
        @power_mode = power_mode
        @accepted_power_modes = ["PS1", "PS2", "REDUCED", "OPERATIONAL"]
        @columns = {"PG indication" => 'A', "Parent" => 'B', "PS1" => 'P', "PS2" => 'Q', "REDUCED" => 'R', "OPERATIONAL" => 'S'}
        @columns_temp_dep = {"PG indication" => 'A', "THERMAL_NAME" => 'B', "CHILD_NAME" => 'C'}
        @document_path = "#{File.expand_path('../',__dir__)}/Data/pwr_good_indicators_list.xlsx"
        @sheet_name_pwr_goods = "PWR_GOODS"
        @sheet_name_temp_dep = "TempDependent"
        @sheet_name_mic_enable_neg = "MIC_ENABLE_NEGATIVE"
        @end_of_list_indicator = "END_OF_LIST"
    end

def get_pwr_good_indicator_status_map

#map format
#key=indicator name
#value = object
#object contains: status: PS1, parent: indicator_name or empty


    puts "power_mode=#{@accepted_power_modes.index(@power_mode)} / #{@power_mode}"
    if @accepted_power_modes.index(@power_mode) != nil then
        xlsx = Roo::Spreadsheet.open(@document_path)
        sheet = xlsx.sheet(@sheet_name_pwr_goods)
        data = {}

        row = 2
        col_pg = @columns.fetch(@columns.keys.first)
        col_power_state = @columns.fetch(@power_mode)
        parentCol = @columns.fetch("Parent")
        data_pwr_goods = {}
        data_temp_dep = {}
        #puts "col_pg: #{col_pg} / col_power_state: #{col_power_state}"
        until sheet.cell(row, col_pg).eql? @end_of_list_indicator
            cell_value = sheet.cell(row, col_pg).to_s
            if cell_value[0,12].eql? "MIC_PWR_GOOD"
                itemInfo = {}
                itemInfo.store("status", sheet.cell(row, col_power_state).to_s)
                if sheet.cell(row,parentCol).kind_of? Integer
                    itemInfo.store("parent",sheet.cell(sheet.cell(row,parentCol),col_pg))
                end
                data_pwr_goods.store(cell_value, itemInfo)
            end
            row+=1
        end
        data.store("pwr_goods",data_pwr_goods)

        col_pg = @columns_temp_dep.fetch(@columns_temp_dep.keys.first)
        col_thermal = @columns_temp_dep.fetch("THERMAL_NAME")
        col_child = @columns_temp_dep.fetch("CHILD_NAME")
        row = 2
        sheet = xlsx.sheet(@sheet_name_temp_dep)
        until sheet.cell(row, col_pg).eql? @end_of_list_indicator
            cell_value = sheet.cell(row, col_pg).to_s
            if cell_value[0,12].eql? "MIC_PWR_GOOD"
                thermals = sheet.cell(row, col_thermal).to_s.strip.split(",")
                children = sheet.cell(row,col_child).to_s.strip.split(",")
                obj = {}
                obj.store("thermals",thermals)
                obj.store("children",children) unless children.length.eql? 0
                data_temp_dep.store(cell_value, obj)
            end
            row+=1
        end
        data.store("pwr_temp_dep", data_temp_dep)

        row = 2
        sheet = xlsx.sheet(@sheet_name_mic_enable_neg)
        mic_en_neg = []
        until sheet.cell(row, 'A').eql? @end_of_list_indicator
            cell_value = sheet.cell(row, 'A').to_s
            if cell_value[0,10].eql? "MIC_ENABLE"
                mic_en_neg.push(cell_value)
            end
            row+=1
        end
        data.store("mic_en_neg", mic_en_neg)

        return data
    else return nil
    end
end





end