require_relative './solve'

EXAMPLE = <<-END
forward 5
down 5
forward 8
up 3
down 8
forward 2
END

class Command

  def initialize(line)
    line =~ /^(forward|up|down) (\d+)$/ or raise "Invalid: #{line.inspect}"
    @command, @amount = [$1, $2.to_i]
  end

  def execute(horiz = 0, depth = 0)
    case @command
    when 'forward'
      [horiz + @amount, depth]
    when 'up'
      [horiz, depth - @amount]
    when 'down'
      [horiz, depth + @amount]
    end
  end

  def aimed_execute(horiz = 0, depth = 0, aim = 0)
    case @command
    when 'forward'
      [horiz + @amount, depth + aim * @amount, aim]
    when 'up'
      [horiz, depth, aim - @amount]
    when 'down'
      [horiz, depth, aim + @amount]
    end
  end

end

solve_with_each(Command, EXAMPLE => 150) do |commands|
  commands.reduce(nil) do |stats, command|
    command.execute(*stats)
  end.reduce(&:*)
end

solve_with_each(Command, EXAMPLE => 900) do |commands|
  commands.reduce(nil) do |stats, command|
    command.aimed_execute(*stats)
  end.first(2).reduce(&:*)
end
