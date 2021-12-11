require_relative './solve'

EXAMPLE = <<-END
  3,4,3,1,2
END

def breed_lantern_fish(text, days:)
  counts = [0] * 9
  text.split(',').each { |v| counts[v.to_i] += 1 }

  days.times do |day|
    counts[(day + 7) % 9] += counts[day % 9]
  end

  counts.reduce(:+)
end

solve_with_text(EXAMPLE => 5934) do |text|
  breed_lantern_fish(text, days: 80)
end

solve_with_text(EXAMPLE => 26984457539) do |text|
  breed_lantern_fish(text, days: 256)
end
