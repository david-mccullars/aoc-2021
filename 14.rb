require_relative './solve'

EXAMPLE = <<-END
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
END

class Polymerization

  def initialize(text)
    @template = text.lines.first.chomp
    @elements = @template.chars.tally.with_default(0)
    @pair_counts = @template.chars.each_cons(2).each_with_counter do |pair, counter|
      counter[pair.join] += 1
    end
    @rules = text.scan(/(..) -> (.)/).to_h
  end

  def apply(qty)
    qty.each { apply_once }
    score
  end

  def apply_once
    @pair_counts = @pair_counts.each_with_counter do |(pair, qty), counter|
      insert = @rules[pair] or next
      [pair[0], insert, pair[1]].each_cons(2) do |new_pair|
        counter[new_pair.join] += qty
      end
      @elements[insert] += qty
    end
  end

  def score
    @elements.values.minmax.reverse.reduce(&:-)
  end

end

solve_with(Polymerization, :text, EXAMPLE => 1588) do |polymerization|
  polymerization.apply(10.times)
end

solve_with(Polymerization, :text, EXAMPLE => 2188189693529) do |polymerization|
  polymerization.apply(40.times)
end
