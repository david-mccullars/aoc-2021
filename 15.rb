require_relative './solve'

EXAMPLE = <<-END
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
END

class Chiton

  include DijkstraFast::ShortestPath

  def initialize(grid)
    @grid = grid
    @size = @tile_size = Math.sqrt(grid.size).to_i
    abort "Grid is not square" unless @size ** 2 == grid.size
  end

  def expand!(factor:)
    @size = @tile_size * factor
    self
  end

  def risk(y, x)
    return unless (0...@size).include?(y)
    return unless (0...@size).include?(x)

    value = @grid[[y % @tile_size, x % @tile_size]]
    ((value + (y / @tile_size) + (x / @tile_size) - 1) % 9) + 1
  end

  def connections(u)
    u.orthogonally_adjacent.each do |v|
      v_risk = risk(*v) or next
      yield v, v_risk
    end
  end

  def shortest
    shortest_distance([0, 0], [@size - 1, @size - 1], progress: true)
  end

end

solve_with_grid_of_numbers(clazz: Chiton, EXAMPLE => 40) do |chiton|
  chiton.shortest
end

solve_with_grid_of_numbers(clazz: Chiton, EXAMPLE => 315) do |chiton|
  chiton.expand!(factor: 5).shortest
end
