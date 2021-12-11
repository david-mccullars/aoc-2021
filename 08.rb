require_relative './solve'

=begin
  0:      1:      2:      3:      4:
 aaaa    ....    aaaa    aaaa    ....
b    c  .    c  .    c  .    c  b    c
b    c  .    c  .    c  .    c  b    c
 ....    ....    dddd    dddd    dddd
e    f  .    f  e    .  .    f  .    f
e    f  .    f  e    .  .    f  .    f
 gggg    ....    gggg    gggg    ....

  5:      6:      7:      8:      9:
 aaaa    aaaa    aaaa    aaaa    aaaa
b    .  b    .  .    c  b    c  b    c
b    .  b    .  .    c  b    c  b    c
 dddd    dddd    ....    dddd    dddd
.    f  e    f  .    f  e    f  .    f
.    f  e    f  .    f  e    f  .    f
 gggg    gggg    ....    gggg    gggg
=end

EXAMPLE = <<-END
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
END

class Solver

  def initialize(inputs)
    @to_consume = inputs.dup
    @digits = {}
  end

  def solve
    consume(digit: 1, size: 2)
    consume(digit: 7, size: 3)
    consume(digit: 4, size: 4)
    consume(digit: 8, size: 7)
    consume(digit: 9, size: 6, matching: 4)
    consume(digit: 0, size: 6, matching: 7)
    consume(digit: 3, size: 5, matching: 7)
    consume(digit: 6, size: 6)
    consume(digit: 5, size: 5, matching: 4, not_matching: 1)
    consume(digit: 2, size: 5)
    @digits
  end

  def consume(digit:, size:, matching: nil, not_matching: nil)
    must_have = @digits.fetch(matching, []) \
              - @digits.fetch(not_matching, [])

    match = @to_consume.index do |chars|
      chars.size == size &&
      chars & must_have == must_have
    end

    @digits[digit] = @to_consume.delete_at(match)
  end

end

class Wiring

  def initialize(line)
    @inputs, @outputs = line.split(' | ').map do |section|
      section.split.map { |s| s.chars.sort }
    end
  end

  def mapped_outputs
    @mapped_outputs ||= Solver.new(@inputs).solve.invert.values_at(*@outputs)
  end

  def count1478
    mapped_outputs.count { |i| [1, 4, 7, 8].include?(i) }
  end

  def display
    mapped_outputs.join.to_i
  end

end

solve_with_each(Wiring, EXAMPLE => 26) do |wirings|
  wirings.sum do |wiring|
    wiring.count1478
  end
end

solve_with_each(Wiring, EXAMPLE => 61229) do |wirings|
  wirings.sum do |wiring|
    wiring.display
  end
end
