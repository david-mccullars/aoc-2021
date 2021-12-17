require_relative './solve'

EXAMPLE = <<-END
target area: x=20..30, y=-10..-5
END

class ProbeLauncher

  def initialize(line)
    @x_min, @x_max, @y_min, @y_max = line.scan(/-?\d+/).map_i
    @x_range = @x_min .. @x_max
    @y_range = @y_min .. @y_max
    raise "y_range produces infinite solutions!" if @y_range.include?(0)
  end

  # At its largest, dx will hit the target in one shot.
  # At it smallest, dx will peter out right as it hits x_min.
  def dx_range
    # (dx + 1) dx / 2 >= x_min
    min_dx = (Integer.sqrt(8 * @x_min + 1) - 1) / 2
    min_dx .. @x_max
  end

  # Best we can do here is the abs bounds of @y_range because
  # dx can reach zero, giving us a lot of possible step counts
  # to reach our target @y_range.  However, the trajectory of
  # y with respect to n (the number of steps) is a parabola.
  # If dy > abs(@y_range) then we will miss the target going
  # up and going down.  (This is only true if our @y_range
  # does not contain 0.  Then we would have infinite solutions.)
  def dy_range
    y_abs_bound = [@y_min.abs, @y_max.abs].max
    -y_abs_bound .. y_abs_bound
  end

  # We achieve max height when dx is minimal and dy is one less
  # than maximal
  def max_height
    dy = dy_range.max - 1
    (dy + 1) * dy / 2
  end

  def hits?(dx, dy)
    x, y = 0, 0
    loop do
      x += dx
      y += dy
      dx = [dx - 1, 0].max
      dy -= 1
      return true if @x_range.include?(x) && @y_range.include?(y)
      return false if x > @x_range.max || y < @y_range.min
    end
  end

  def shots_that_hit
    dx_range.to_a.product(dy_range.to_a).select do |dx, dy|
      hits?(dx, dy)
    end
  end

end

solve_with(ProbeLauncher, :text, EXAMPLE => 45) do |launcher|
  launcher.max_height
end

solve_with(ProbeLauncher, :text, EXAMPLE => 112) do |launcher|
  launcher.shots_that_hit.count
end
