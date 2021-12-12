require_relative './solve'

EXAMPLE = <<-END
start-A
start-b
A-c
A-b
b-d
A-end
b-end
END

EXAMPLE_2 = <<-END
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
END

EXAMPLE_3 = <<-END
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
END

class CaveSystem

  SMALL_CAVES = /^[a-z]{1,2}$/

  def initialize(lines)
    @connections = {}
    lines.each do |line|
      line.split('-', 2).permutation do |cave1, cave2|
        @connections[cave1] ||= []
        @connections[cave1] << cave2 unless cave2 == 'start'
      end
    end
  end

  def paths(*path, can_revisit_small_cave: false)
    path = ['start'] if path.empty?
    @connections[path[-1]].sum do |cave|
      if cave == 'end'
        1
      elsif path.include?(cave) && small_caves.include?(cave)
        can_revisit_small_cave ? paths(*path, cave, can_revisit_small_cave: false) : 0
      else
        paths(*path, cave, can_revisit_small_cave: can_revisit_small_cave)
      end
    end
  end

  def small_caves
    @small_caves ||= @connections.keys.grep(SMALL_CAVES)
  end

  def small_cave_visits(path)
    path.tally.values_at(*small_caves).compact
  end

end

solve_with(CaveSystem, EXAMPLE => 10, EXAMPLE_2 => 19, EXAMPLE_3 => 226) do |system|
  system.paths(can_revisit_small_cave: false)
end

solve_with(CaveSystem, EXAMPLE => 36, EXAMPLE_2 => 103, EXAMPLE_3 => 3509) do |system|
  system.paths(can_revisit_small_cave: true)
end
