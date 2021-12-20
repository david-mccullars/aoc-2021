require_relative './solve'

EXAMPLE = <<-END
..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###
END

class ImageEnhancer

  NEIGHBORHOOD = %i[ul l dl u c d ur r dr] # order matters here

  def initialize(lines)
    algo, _, *grid = lines

    @algo = algo.chars.map { |c| c == '#' }

    @grid = Hash.new { false } # The void starts dark
    grid.each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        @grid[[x, y]] = c == '#'
      end
    end

    @xmin, @xmax = @grid.keys.map(&:first).minmax
    @ymin, @ymax = @grid.keys.map(&:last).minmax
  end

  def each_pixel
    (@ymin - 2 .. @ymax + 2).each do |y|
      (@xmin - 2 .. @xmax + 2).each do |x|
        yield [x, y]
      end
    end
  end

  def apply
    new_grid = {}
    each_pixel do |pixel|
      new_grid[pixel] = enhance(pixel)
    end
    new_grid.default = enhance_the_void
    @grid = new_grid
    @xmin, @xmax = @xmin - 2, @xmax + 2
    @ymin, @ymax = @ymin - 2, @ymax + 2
  end

  def enhance_the_void
    @algo[@grid[:void] ? 511 : 0]
  end

  def enhance(pixel)
    idx = 0
    pixel.adjacent(NEIGHBORHOOD).each do |pixel2|
      idx = idx << 1
      idx += 1 if @grid[pixel2]
    end
    @algo[idx]
  end

  def lit
    @grid.count { |_, v| v }
  end
  
end

solve_with(ImageEnhancer, EXAMPLE => 35) do |enhancer|
  2.times { enhancer.apply }
  enhancer.lit
end

solve_with(ImageEnhancer, EXAMPLE => 3351) do |enhancer|
  50.times { enhancer.apply }
  enhancer.lit
end
