require_relative './solve'

EXAMPLE = <<-END
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
END

class VentLine

  def initialize(line)
    raise "Invalid line #{line.inspect}" unless line =~ /^(\d+),(\d+) -> (\d+),(\d+)$/
    @x1, @y1, @x2, @y2 = [$1, $2, $3, $4].map_i
  end

  def diagonal?
    @x1 != @x2 && @y1 != @y2
  end

  def x_inc
    @x_inc ||= @x1 < @x2 ? 1
             : @x1 > @x2 ? -1
             : 0
  end

  def y_inc
    @y_inc ||= @y1 < @y2 ? 1
             : @y1 > @y2 ? -1
             : 0
  end

  def points
    x, y = @x1, @y1
    points = [[x, y]]
    until x == @x2 && y == @y2
      x += x_inc
      y += y_inc
      points << [x, y]
    end
    points
  end

end

def vent_field_overlap_count(vent_lines)
  vent_lines.flat_map(&:points)
            .tally
            .count { |_, occurrences| occurrences > 1 }
end

solve_with_each(VentLine, EXAMPLE => 5) do |vent_lines|
  vent_lines.reject!(&:diagonal?)
  vent_field_overlap_count(vent_lines)
end

solve_with_each(VentLine, EXAMPLE => 12) do |vent_lines|
  vent_field_overlap_count(vent_lines)
end
