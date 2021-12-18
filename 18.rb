require_relative './solve'
require 'json'

EXAMPLE = <<-END
[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
END

class NestedPair < Array

  def self.for(lines)
    lines.map { |line| new(JSON.parse(line)) }
  end

  attr_reader :parent

  def initialize(nested_pair, parent = nil)
    raise "Nested Pair must have exactly two elements" unless nested_pair.size == 2
    super(nested_pair.map { |d| decorate(d) })
    @parent = parent
  end

  def decorate(obj)
    case obj
    when Array, NestedPair
      NestedPair
    else
      MutableInt
    end.new(obj, self)
  end

  def +(obj)
    NestedPair.new([self, obj]).tap(&:reduce)
  end

  def reduce
    :continue while explode || split
  end

  def explode
    pair = flatten(3).grep(NestedPair).first or return false
    pair.mutate_prev(pair[0])
    pair.mutate_next(pair[1])
    pair.parent&.replace(pair => MutableInt.new(0, pair.parent))
    true
  end

  def split
    number = flatten.grep_v(NestedPair).detect { |i| i >= 10 } or return false
    half = number / 2
    pair = NestedPair.new([half, number - half], number.parent)
    number.parent&.replace(number => pair)
    true
  end

  def mutate_prev(value)
    return unless parent
    return parent.mutate_prev(value) if equal?(parent[0])
    Array(parent[0]).flatten.last.mutate_by(value)
  end

  def mutate_next(value)
    return unless parent
    return parent.mutate_next(value) if equal?(parent[1])
    Array(parent[1]).flatten.first.mutate_by(value)
  end

  def replace(**replacements)
    replacements.each do |obj, replacement|
      self[index(obj)] = replacement
    end
  end

  def to_i
    3 * self[0].to_i + 2 * self[1].to_i
  end

end

class MutableInt < SimpleDelegator

  attr_reader :parent

  def initialize(value, parent)
    super(value.to_i)
    @parent = parent
  end

  def mutate_by(value)
    @delegate_sd_obj += value
  end

end

solve(EXAMPLE => 4140) do |lines|
  NestedPair.for(lines).reduce(&:+).to_i
end

solve(EXAMPLE => 3993) do |lines|
  NestedPair.for(lines).permutation(2).map do |a, b|
    (a + b).to_i
  end.max
end
