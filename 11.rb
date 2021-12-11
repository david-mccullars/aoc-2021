require_relative './solve'

EXAMPLE = <<-END
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
END

class Dumbo

  def initialize(levels)
    @levels = levels
    @flash_count = 0
  end

  def step_once
    @levels = @levels.transform_values { |v| v + 1 }
    flashes = @levels.select { |k, v| v == 10 }.keys
    until flashes.empty?
      pos = flashes.pop
      @flash_count += 1
      pos.neighborhood.each do |p2|
        next unless @levels.key?(p2)
        @levels[p2] += 1
        flashes << p2 if @levels[p2] == 10
      end
    end
    @levels = @levels.transform_values { |v| v > 10 ? 0 : v }
    nil
  end

  def step(count:)
    count.times { step_once }
    @flash_count
  end

  def step_till_we_have_magic!
    count = @flash_count
    n = 0
    loop do
      step_once
      count, prev = @flash_count, count
      n += 1
      break if count - prev == @levels.size
    end
    n
  end

  # For fun
  def to_s
    10.times.map do |row|
      10.times.map { |col| @levels[[row, col]].to_s }.join
    end.join("\n")
  end

end

solve_with_grid_of_numbers(clazz: Dumbo, EXAMPLE => 1656) do |dumbo|
  dumbo.step(count: 100)
end

solve_with_grid_of_numbers(clazz: Dumbo, EXAMPLE => 195) do |dumbo|
  dumbo.step_till_we_have_magic!
end
