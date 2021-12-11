require_relative './solve'

EXAMPLE = <<-END
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
END

class NavSyntax

  CHUNKS = %w[() [] {} <>].map { |s| s.chars.reverse }.to_h
  ERROR_COSTS = CHUNKS.keys.zip([3, 57, 1197, 25137]).to_h
  COMPLETION_POINTS = CHUNKS.values.zip(1.upto(4)).to_h

  attr_reader :error

  def initialize(line)
    @error = 0
    @stack = []
    line.each_char do |c|
      case c
      when *CHUNKS.values
        @stack << c
      when *CHUNKS.keys
        @error = ERROR_COSTS[c] unless @stack.pop == CHUNKS[c]
      end
    end
  end

  def error?
    @error.positive?
  end

  def completion_score
    @stack.reverse.reduce(0) do |s, c|
      s * 5 + COMPLETION_POINTS[c]
    end
  end

end

solve_with_each(NavSyntax, EXAMPLE => 26397) do |nav_syntaxes|
  nav_syntaxes.sum(&:error)
end

solve_with_each(NavSyntax, EXAMPLE => 288957) do |nav_syntaxes|
  scores = nav_syntaxes.reject(&:error?).map(&:completion_score)
  scores.sort[scores.size / 2]
end
