require 'csv'

class HandleRouting

  def initialize
    @table = CSV.parse(File.read("C:\\Cosmos\\PROCEDURES\\Operations\\Routing\\operational_routing_table.csv"), headers: true)
  end

  def convert_to_direction(s)
    if(s.to_s.downcase == "s")
      return "SOUTH_CLOSED"
    end
    if(s.to_s.downcase == "n")
      return "NORTH_CLOSED"
    end
    if(s.to_s.downcase == "w")
      return "WEST_CLOSED"
    end
    return "EAST_CLOSED"

  end


  def getRoutingPathWithMicronID(micron_id)
    f = @table.by_row[micron_id-1].to_s.split(",")
    ids = []
    directions = []

    for i in 2..f.length()
      if(f[i].to_s.strip != "")
        ids << "MICRON_".concat((f[i].to_s.strip[0..-2]))
        directions << convert_to_direction(f[i].to_s.strip[-1])
      end

    end
    return ids,directions
  end

end



