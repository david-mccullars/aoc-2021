require_relative './solve'

EXAMPLE = <<-END
Player 1 starting position: 4
Player 2 starting position: 8
END

class DeterministicDiracDieGame

  def initialize(lines)
    @pos = lines.map { |line| line[/Player \d+ starting position: (\d+)/, 1].to_i - 1 }
    @scores = [0, 0]
    @die = 0
    @winning_score = 1_000
  end

  def play
    :continue while move(player: 0) && move(player: 1)
  end

  def move(player:)
    total = 3.times.sum { roll }
    @pos[player] = (@pos[player] + total) % 10
    @scores[player] += @pos[player] + 1
    @scores[player] < @winning_score
  end

  def roll
    (@die % 100) + 1
  ensure
    @die += 1
  end

  def checksum
    @die * @scores.min
  end

end

class QuantumDiracDieGame

  extend WithMemoizedMethods

  DIRAC_3_ROLL_TOTALS = {
    # sum => occurences
    3 => 1,
    4 => 3,
    5 => 6,
    6 => 7,
    7 => 6,
    8 => 3,
    9 => 1,
  }

  def initialize(lines)
    @pos = lines.map { |line| line[/Player \d+ starting position: (\d+)/, 1].to_i - 1 }
    @scores = [0, 0]
    @winning_score = 21
  end

  def play(pos0 = @pos[0], score0 = @scores[0], pos1 = @pos[1], score1 = @scores[1], player = 0)
    DIRAC_3_ROLL_TOTALS.each_with_object([0, 0]) do |(sum, qty), wins|
      pos0new = (pos0 + sum) % 10
      score0new = score0 + pos0new + 1
      if score0new < @winning_score
        w0, w1 = play(pos1, score1, pos0new, score0new, (player + 1) % 2)
        wins[0] += qty * w0
        wins[1] += qty * w1
      else
        wins[player] += qty
      end
    end
  end

  memoize :play

end

solve_with(DeterministicDiracDieGame, EXAMPLE => 739785) do |game|
  game.play
  game.checksum
end

solve_with(QuantumDiracDieGame, EXAMPLE => 444356092776315) do |game|
  win_counts = game.play
  win_counts.max
end
