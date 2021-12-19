require_relative './solve'
require 'matrix'

EXAMPLEX = <<-END
--- scanner 0 ---
0,2
4,1
3,3

--- scanner 1 ---
-1,-1
-5,0
-2,1
END
EXAMPLE = <<-END
--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14
END

Vector.class_eval do

  def manhattan_distance(v2)
    to_a.zip(v2.to_a).sum do |a, b|
      (a - b).abs
    end
  end

end

class Scanner

  FUDGE = 10

  attr_reader :id, :coords, :delta

  def initialize(id, coords, delta = Vector[0,0,0])
    @id = id
    @delta = delta
    @coords = coords.strip.lines.map do |line|
      Vector[*line.split(',').map_i]
    end if coords.is_a?(String)
    @coords ||= coords
  end

  def fingerprints
    @fingerprints ||= coords.permutation(3).each_with_object({}) do |combo, h|
      a, b, c = combo
      next if (b.to_a <=> c.to_a) < 0 # Avoid duplication
      angle = (a - b).angle_with(a - c).round(FUDGE)
      h[angle] ||= []
      h[angle] << a
    end
  end

end

class ScannerRelativity

  OVERLAP = 12
  ROTATIONS = [
    [1,0,0,0,1,0,0,0,1],
    [1,0,0,0,0,-1,0,1,0],
    [1,0,0,0,-1,0,0,0,-1],
    [1,0,0,0,0,1,0,-1,0],
    [0,-1,0,1,0,0,0,0,1],
    [0,0,1,1,0,0,0,1,0],
    [0,1,0,1,0,0,0,0,-1],
    [0,0,-1,1,0,0,0,-1,0],
    [-1,0,0,0,-1,0,0,0,1],
    [-1,0,0,0,0,-1,0,-1,0],
    [-1,0,0,0,1,0,0,0,-1],
    [-1,0,0,0,0,1,0,1,0],
    [0,1,0,-1,0,0,0,0,1],
    [0,0,1,-1,0,0,0,-1,0],
    [0,-1,0,-1,0,0,0,0,-1],
    [0,0,-1,-1,0,0,0,1,0],
    [0,0,-1,0,1,0,1,0,0],
    [0,1,0,0,0,1,1,0,0],
    [0,0,1,0,-1,0,1,0,0],
    [0,-1,0,0,0,-1,1,0,0],
    [0,0,-1,0,-1,0,-1,0,0],
    [0,-1,0,0,0,1,-1,0,0],
    [0,0,1,0,1,0,-1,0,0],
    [0,1,0,0,0,-1,-1,0,0],
  ].map { |a| Matrix[*a.each_slice(3)] }

  def initialize(text)
    @scanners = text.split(/--- scanner (\d+) ---/)[1..].each_slice(2).map do |id, coords|
      Scanner.new(id.to_i, coords)
    end
  end

  def unique_beacons
    scanners_in_absolute_space.flat_map(&:coords).uniq
  end

  def scanners_in_absolute_space(h = relative_to(@scanners.first))
    @scanners.map do |s|
      next @scanners.first if s == @scanners.first
      delta, rotation = h[s]
      Scanner.new(s.id, s.coords.map { |v| rotation * v + delta }, delta)
    end
  end

  def relative_to(s1)
    h = local_relativity
    until h[s1].size == @scanners.size - 1
      h.keys.each do |s2|
        next if s1 == s2 || h[s1][s2]
        s3 = (h[s1].keys & h.keys).detect { |s3| h[s3][s2] } or next
        delta13, rotation13 = h[s1][s3]
        delta32, rotation32 = h[s3][s2]
        h[s1][s2] = [rotation13 * delta32 + delta13, rotation13 * rotation32]
      end
    end
    h[s1]
  end

  def local_relativity
    @local_relativity ||= {}.tap do |h|
      @scanners.combination(2).each do |s1, s2|
        rel = relativity_between(s1, s2) or next
        h[s1] ||= {}
        h[s1][s2] = rel
        h[s2] ||= {}
        delta, rotation = rel
        h[s2][s1] = [rotation.transpose * -delta, rotation.transpose]
      end
    end
  end

  def relativity_between(scanner1, scanner2)
    possible_overlays(scanner1, scanner2).each do |v1, v2|
      ROTATIONS.map do |rotation|
        delta = v1 - rotation * v2
        in_common = scanner2.coords.count do |v3|
          scanner1.coords.include?(rotation * v3 + delta)
        end
        return delta, rotation if in_common >= OVERLAP
      end
    end
    nil
  end

  def possible_overlays(scanner1, scanner2)
    f1 = scanner1.fingerprints
    f2 = scanner2.fingerprints
    k = (f1.keys & f2.keys).min_by do |k|
      [f1[k].size, f2[k].size].min
    end
    k ? f1[k].product(f2[k]) : []
  end

  def manhattan_distances
    scanners_in_absolute_space.combination(2).map do |s1, s2|
      s1.delta.manhattan_distance(s2.delta)
    end
  end

end

solve_with(ScannerRelativity, :text, EXAMPLE => 79) do |relativity|
  relativity.unique_beacons.count
end

solve_with(ScannerRelativity, :text, EXAMPLE => 3621) do |relativity|
  relativity.manhattan_distances.max
end
