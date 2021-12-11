require_relative './solve'

EXAMPLE = <<-END
16,1,2,0,4,2,7,1,2,14
END

class Crabs

  def initialize(positions)
    @positions = positions
    @min, @max = positions.minmax
  end

  def least_fuel
    @min.upto(@max).map do |target_position|
      @positions.sum do |current_position|
        yield (target_position - current_position).abs
      end
    end.min
  end

end

solve_with_line_of_numbers(clazz: Crabs, EXAMPLE => 37) do |crabs|
  crabs.least_fuel do |d|
    d
  end
end

solve_with_line_of_numbers(clazz: Crabs, EXAMPLE => 168) do |crabs|
  crabs.least_fuel do |d|
    (d * (d + 1)) / 2
  end
end
