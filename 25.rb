require_relative './solve'

EXAMPLE = <<-END
v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>
END

class Herds

  def initialize(lines)
    @herds = {}
    lines.each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        @herds[[x, y]] = c unless c == '.'
      end
    end
    @max_x = lines.first.size
    @max_y = lines.size
  end

  def step_until_stopped
    (1..).each { |n| return n unless another_step }
  end

  def another_step
    [step_herd_east, step_herd_south].any?
  end

  def step_herd_east
    step_herd('>') do |x, y|
      [(x + 1) % @max_x, y]
    end
  end

  def step_herd_south
    step_herd('v') do |x, y|
      [x, (y + 1) % @max_y]
    end
  end

  def step_herd(type)
    any_moved = false
    new_herds = @herds.dup
    @herds.each do |(x, y), c|
      next unless c == type
      new_x, new_y = yield(x, y)
      if @herds[[new_x, new_y]].nil?
        any_moved = true
        new_herds[[x, y]] = nil
        new_herds[[new_x, new_y]] = c
      end
    end
    @herds = new_herds
    any_moved
  end

end

solve_with(Herds, EXAMPLE => 58) do |herds|
  herds.step_until_stopped
end

puts "====== CLAIM THE FINAL GOLD STAR!!! ======"
