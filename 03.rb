require_relative './solve'

EXAMPLE = <<-END
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
END

######################## PART A ########################

def basic_rating(lines)
  lines.map(&:chars).transpose.map do |row|
    bit_comparison = 2 * row.grep('1').size - lines.size
    raise "Oh, no! We have a tie" if bit_comparison == 0
    yield(bit_comparison) ? 1 : 0
  end.join.to_i(2)
end

solve(EXAMPLE => 198) do |lines|
  gamma = basic_rating(lines, &:positive?)
  epsilon = basic_rating(lines, &:negative?) # Yes, we could bit-flip, but this is more fun!
  gamma * epsilon
end

######################## PART B ########################

def filter_rating(lines)
  position = 0
  while lines.size > 1
    lines0, lines1 = lines.partition do |line|
      line[position].to_i == 0
    end
    lines = yield(lines0.size, lines1.size) ? lines0 : lines1
    position += 1
  end
  lines.first.to_i(2)
end

solve(EXAMPLE => 230) do |lines|
  o2_rating = filter_rating(lines) { |s0, s1| s0 > s1 }
  co2_rating = filter_rating(lines) { |s0, s1| s0 <= s1 }
  o2_rating * co2_rating
end
