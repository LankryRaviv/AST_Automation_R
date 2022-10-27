# frozen_string_literal: true

require 'Operations/MICRON/Routing/constants'

# rubocop:disable Lint/SuppressedException
begin
  require 'colorize'
rescue LoadError
end
# rubocop:enable Lint/SuppressedException

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/CyclomaticComplexity

# Printing
class Printing
  def self.print_map(matrix)
    unless matrix.instance_of? MicronsMatrix
      puts "ERROR matrix: #{matrix.class}"
      return
    end

    puts "╔#{'═══╦' * 13}═══╗"

    matrix.map.each_with_index do |row, row_index|
      print '║'
      row.each do |micron|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        micron_id = 'CS' if micron_id.zero?
        print micron_id.to_s.center(3)

        print '║'
      end

      puts
      puts "╟#{'═══╬' * 13}═══╢" if row_index < 13
      puts "╚#{'═══╩' * 13}═══╝" if row_index == 13
    end
  end

  def self.print_connections(matrix)
    unless matrix.instance_of? MicronsMatrix
      puts "ERROR matrix: #{matrix.class}"
      return
    end

    puts "╔#{'═══╦' * 13}═══╗"

    matrix.map.each_with_index do |row, row_index|
      south = Array.new(Microns::MICRON_ARRAY_SIZE) { false }

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        micron_id = 'CS' if micron_id.zero?
        print micron_id.to_s.center(3)

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south[col_index] = true unless micron.connections.south.nil?
      end

      puts
      if row_index < 13
        print '╟'
        south.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        puts '╢'
      else
        puts "╚#{'═══╩' * 13}═══╝"
      end
    end
  end

  def self.print_rings(matrix)
    unless matrix.instance_of? MicronsMatrix
      puts "ERROR matrix: #{matrix.class}"
      return
    end

    puts "╔#{'═══╦' * 13}═══╗"

    matrix.map.each_with_index do |row, row_index|
      south = Array.new(Microns::MICRON_ARRAY_SIZE) { false }

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        ring = if micron_id.zero?
                 'CS'
               else
                 micron.ring
               end

        case ring
        when 'CS'
          print ring.center(3).black.on_yellow
        when 'A'
          print ring.center(3).on_blue
        when 'B'
          print ring.center(3).on_cyan
        when 'C'
          print ring.center(3).on_light_red
        when 'D'
          print ring.center(3).on_light_blue
        when 'E'
          print ring.center(3).on_green
        when 'F'
          print ring.center(3).on_light_magenta
        when 'G'
          print ring.center(3).on_red
        else
          print ring.center(3)
        end

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south[col_index] = true unless micron.connections.south.nil?
      end

      puts
      if row_index < 13
        print '╟'
        south.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        puts '╢'
      else
        puts "╚#{'═══╩' * 13}═══╝"
      end
    end
  end

  def self.print_micron_rings(matrix)
    unless matrix.instance_of? MicronsMatrix
      puts "ERROR matrix: #{matrix.class}"
      return
    end

    puts ['Rings:', 'A'.on_blue, 'B'.on_cyan, 'C'.on_light_red, 'D'.on_light_blue,
          'E'.on_green, 'F'.on_light_magenta, 'G'.on_red].join(' ')
    puts "╔#{'═══╦' * 13}═══╗"

    matrix.map.each_with_index do |row, row_index|
      south = Array.new(Microns::MICRON_ARRAY_SIZE) { false }

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id.to_s.center(3) if micron.instance_of? Micron

        ring = if micron.micron_id.zero?
                 'CS'
               else
                 micron.ring
               end

        case ring
        when 'CS'
          print ring.center(3).black.on_yellow
        when 'A'
          print micron_id.on_blue
        when 'B'
          print micron_id.on_cyan
        when 'C'
          print micron_id.on_light_red
        when 'D'
          print micron_id.on_light_blue
        when 'E'
          print micron_id.on_green
        when 'F'
          print micron_id.on_light_magenta
        when 'G'
          print micron_id.on_red
        else
          print micron_id
        end

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south[col_index] = true unless micron.connections.south.nil?
      end

      puts
      if row_index < 13
        print '╟'
        south.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        puts '╢'
      else
        puts "╚#{'═══╩' * 13}═══╝"
      end
    end
  end

  def self.print_reroute(matrix, routes_forward, routes_backward, target_micron_id)
    unless matrix.instance_of? MicronsMatrix
      puts "ERROR matrix: #{matrix.class}"
      return
    end

    end_micron_id = routes_backward.first.micron_id
    routes_backward = routes_backward.map { |route| route.backward.to_i }

    forward_micron_id = routes_forward.first.micron_id
    routes_forward = routes_forward.map { |route| route.forward.to_i }.flatten(1)

    puts "#{'Backward'.center(58)}#{'Forward'.center(58)}"
    puts "╔#{'═══╦' * 13}═══╗" * 2

    matrix.map.each_with_index do |row, row_index|
      south_backward = Array.new(Microns::MICRON_ARRAY_SIZE) { false }
      south_forward = Array.new(Microns::MICRON_ARRAY_SIZE) { false }

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        micron_to_s = micron_id.to_s.center(3)
        micron_to_s = 'CS ' if micron_id.zero?

        if routes_backward.include? micron_id
          if target_micron_id == micron_id
            print micron_to_s.on_blue
          else
            print micron_to_s.on_green
          end
        elsif Microns::CS_MICRON_ID == micron_id
          print micron_to_s.black.on_yellow
        elsif end_micron_id == micron_id
          if target_micron_id == micron_id
            print micron_to_s.on_blue
          else
            print micron_to_s.on_red
          end
        else
          print micron_to_s
        end

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south_backward[col_index] = true unless micron.connections.south.nil?
      end

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        micron_to_s = micron_id.to_s.center(3)
        micron_to_s = 'CS ' if micron_id.zero?

        if Microns::CS_MICRON_ID == micron_id
          print micron_to_s.black.on_yellow
        elsif forward_micron_id == micron_id
          print micron_to_s.on_blue
        elsif routes_forward.include? micron_id
          print micron_to_s.on_green
        else
          print micron_to_s
        end

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south_forward[col_index] = true unless micron.connections.south.nil?
      end

      puts
      if row_index < 13
        print '╟'
        south_backward.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        print '╢╟'
        south_forward.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        puts '╢'
      else
        puts "╚#{'═══╩' * 13}═══╝" * 2
      end
    end
  end

  def self.print_route(matrix, routes, target_micron_id = nil)
    unless matrix.instance_of? MicronsMatrix
      puts "ERROR matrix: #{matrix.class}"
      return
    end

    end_micron_id = routes.first.micron_id
    routes_backward = routes.map { |route| route.backward.to_i }

    routes_forward = if target_micron_id.nil?
                       routes.map { |route| route.forward.to_i }
                     else
                       routes.map { |route| route.forward.to_i if route.micron_id == target_micron_id }
                     end.flatten(1)

    puts "#{'Backward'.center(58)}#{'Forward'.center(58)}"
    puts "╔#{'═══╦' * 13}═══╗" * 2

    matrix.map.each_with_index do |row, row_index|
      south_backward = Array.new(Microns::MICRON_ARRAY_SIZE) { false }
      south_forward = Array.new(Microns::MICRON_ARRAY_SIZE) { false }

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        micron_to_s = micron_id.to_s.center(3)
        micron_to_s = 'CS ' if micron_id.zero?

        if Microns::CS_MICRON_ID == micron_id
          print micron_to_s.black.on_yellow
        elsif end_micron_id == micron_id
          if target_micron_id == micron_id
            print micron_to_s.on_blue
          else
            print micron_to_s.on_red
          end
        elsif routes_backward.include? micron_id
          if target_micron_id == micron_id
            print micron_to_s.on_blue
          else
            print micron_to_s.on_green
          end
        else
          print micron_to_s
        end

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south_backward[col_index] = true unless micron.connections.south.nil?
      end

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        micron_to_s = micron_id.to_s.center(3)
        micron_to_s = 'CS ' if micron_id.zero?

        if Microns::CS_MICRON_ID == micron_id
          print micron_to_s.black.on_yellow
        elsif target_micron_id == micron_id
          print micron_to_s.on_blue
        elsif end_micron_id == micron_id
          print micron_to_s.on_red
        elsif routes_forward.include? micron_id
          print micron_to_s.on_green
        else
          print micron_to_s
        end

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south_forward[col_index] = true unless micron.connections.south.nil?
      end

      puts
      if row_index < 13
        print '╟'
        south_backward.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        print '╢╟'
        south_forward.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        puts '╢'
      else
        puts "╚#{'═══╩' * 13}═══╝" * 2
      end
    end
  end

  def self.print_route_backward(matrix, routes, target_micron_id = nil)
    unless matrix.instance_of? MicronsMatrix
      puts "ERROR matrix: #{matrix.class}"
      return
    end

    end_micron_id = routes.first.micron_id
    routes = routes.map { |route| route.backward.to_i }

    puts "╔#{'═══╦' * 13}═══╗"

    matrix.map.each_with_index do |row, row_index|
      south = Array.new(Microns::MICRON_ARRAY_SIZE) { false }

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        micron_to_s = micron_id.to_s.center(3)
        micron_to_s = 'CS ' if micron_id.zero?

        if Microns::CS_MICRON_ID == micron_id
          print micron_to_s.black.on_yellow
        elsif end_micron_id == micron_id
          print micron_to_s.on_red
        elsif routes.include? micron_id
          if target_micron_id == micron_id
            print micron_to_s.on_blue
          else
            print micron_to_s.on_green
          end
        else
          print micron_to_s
        end

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south[col_index] = true unless micron.connections.south.nil?
      end

      puts
      if row_index < 13
        print '╟'
        south.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        puts '╢'
      else
        puts "╚#{'═══╩' * 13}═══╝"
      end
    end
  end

  def self.print_route_forward(matrix, routes, target_micron_id = nil)
    unless matrix.instance_of? MicronsMatrix
      puts "ERROR matrix: #{matrix.class}"
      return
    end

    end_micron_id = routes.first.micron_id

    routes = if target_micron_id.nil?
               routes.map { |route| route.forward.to_i }
             else
               routes.map { |route| route.forward.to_i if route.micron_id == target_micron_id }
             end.flatten(1)

    puts "╔#{'═══╦' * 13}═══╗"

    matrix.map.each_with_index do |row, row_index|
      south = Array.new(Microns::MICRON_ARRAY_SIZE) { false }

      print '║'
      row.each_with_index do |micron, col_index|
        print "#{' ' * 3}║" if micron.nil?
        next if micron.nil?

        micron_id = micron.micron_id if micron.instance_of? Micron

        micron_to_s = micron_id.to_s.center(3)
        micron_to_s = 'CS ' if micron_id.zero?

        if Microns::CS_MICRON_ID == micron_id
          print micron_to_s.black.on_yellow
        elsif end_micron_id == micron_id
          print micron_to_s.on_red
        elsif target_micron_id == micron_id
          print micron_to_s.on_blue
        elsif routes.include? micron_id
          print micron_to_s.on_green
        else
          print micron_to_s
        end

        print '║' if micron.connections.east.nil?
        print ' ' unless micron.connections.east.nil?

        south[col_index] = true unless micron.connections.south.nil?
      end

      puts
      if row_index < 13
        print '╟'
        south.each_with_index do |v, i|
          print "#{(v ? ' ' : '═') * 3}#{i < 13 ? '╬' : ''}"
        end
        puts '╢'
      else
        puts "╚#{'═══╩' * 13}═══╝"
      end
    end
  end

  def self.print_route_recursive(routing, micron_id, reverse, seperator = ', ')
    unless routing.instance_of? RoutingMatrix
      puts "ERROR routing: #{routing.class}"
      return
    end

    routes = routing.routes

    route = routes[micron_id] unless micron_id.zero?

    return '' if route.nil? || route.backward.to_i.zero?

    local = "#{seperator}#{route.backward.to_i}#{route.backward.to_s(reverse: reverse)}"
    path = print_route_recursive(routing, route.backward.to_i, reverse, seperator)

    if reverse
      "#{path}#{local}"
    else
      "#{local}#{path}"
    end
  end

  def self.print_path(route_path, reverse, seperator = ', ')
    path = ''

    route_path.each do |route|
      route = "#{route.micron_id}#{route.backward.to_s(reverse: reverse)}"

      path = if reverse
               "#{path}#{path.length.zero? ? '' : seperator}#{route}"
             else
               "#{route}#{path.length.zero? ? '' : seperator}#{path}"
             end
    end

    path
  end

  def self.print_routes(routes, rings_filter)
    routes.matrix.microns.each_with_index do |micron, id|
      next if micron.nil?
      next if id.zero?

      next unless rings_filter.include? routes.matrix.microns[id].ring

      micron_id = id.to_s.rjust(3)

      route = routes.determine_lsl_forward_route(id)
      puts "MicronID #{micron_id}: (#{route.length.to_s.rjust(2)}) -> #{Printing.print_path(route, false)}"

      route = routes.determine_lsl_backward_route(id).reverse
      puts "MicronID #{micron_id}: (#{route.length.to_s.rjust(2)}) <- #{Printing.print_path(route, true)}"
    end
  end

  def self.print_cosmos_routing(routes, rings_filter)
    routes.routes.each do |route|
      next if route.nil?

      micron_id = route.micron_id
      next if micron_id.zero?

      next if !rings_filter.nil? && !(rings_filter.include? routes.matrix.microns[micron_id].ring)

      lsl_routing = route.forward.bitmask | route.backward.bitmask
      hsl_routing = route.hsl[:forward].bitmask | route.hsl[:backward].bitmask
      time_tag_delay = route.time_tag_delay
      whole_frame_delay = route.whole_frame_delay
      chain_id = 0

      data = [
        micron_id,
        chain_id,
        lsl_routing,
        hsl_routing,
        whole_frame_delay,
        time_tag_delay
      ].join(', ')

      puts "#{data} # Location #{route.location.to_s.ljust(2)}"
    end
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/CyclomaticComplexity
