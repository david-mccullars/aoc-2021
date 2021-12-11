require_relative './solve'

EXAMPLE = <<-END
2199943210
3987894921
9856789892
8767896789
9899965678
END

class HeightMap

  COLORS  = [31, 32, 33, 34, 35, 36, 37]
  SYMBOLS = [*('a' .. 'z'), *('A'..'Z'), *('0'..'9')] + %w[@ # $ % & * + = : ~]
  FILLS   = COLORS.product(SYMBOLS).map { |c, s| "\e[#{c}m#{s * 2}\e[0m" }

  def initialize(heights)
    @heights = heights
  end

  def edge?(pos)
    @heights[pos] >= EDGE_HEIGHT
  end

  def lowest_points
    @heights.select do |pos, height|
      adjacent_heights = @heights.values_at(*pos.orthogonally_adjacent)
      height < adjacent_heights.compact.min
    end
  end

  def risk_level
    lowest_points.values.sum { |v| v + 1 }
  end

  def basin_scan(pos, in_basin = Set.new)
    pos.orthogonally_adjacent.each do |p|
      next if in_basin.include?(p) || @heights.fetch(p, 9) == 9
      basin_scan(p, in_basin << p)
    end
    in_basin
  end

  def basins
    @basins ||= lowest_points.keys.map do |pos|
      basin_scan(pos)
    end
  end

  def largest_basin_sizes(number = 3)
    basins.map(&:size).sort.last(number)
  end

  def colorize_basins
    basins.zip(FILLS.shuffle).each_with_object([]) do |(basin, fill), map|
      basin.each do |row, col|
        map[row] ||= []
        map[row][col] = fill
      end
    end.each do |row|
      $stderr.puts row.map { |v| v || "  " }.join
    end
    $stderr.puts
  end

end

solve_with_grid_of_numbers(clazz: HeightMap, EXAMPLE => 15) do |height_map|
  height_map.risk_level
end

solve_with_grid_of_numbers(clazz: HeightMap, EXAMPLE => 1134) do |height_map|
  height_map.tap(&:colorize_basins).largest_basin_sizes.reduce(&:*)
end
