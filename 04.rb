require_relative './solve'

EXAMPLE = <<-END
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
END

####################################################################

class Bingo

  def initialize(lines)
    @nums = lines.shift.split(',').map_i

    @boards = lines.each_slice(6).map do |board|
      Board.new(board[1..-1])
    end
  end

  def play
    scores = []
    @nums.each do |num|
      @boards.reject(&:won?).each do |board|
        board.mark(num)
        if board.won?
          scores << board.score(num)
        end
      end
    end
    scores
  end

end

####################################################################

class Board

  def initialize(lines)
    @numbers = lines.map do |line|
      line.scan(/\d+/).map_i
    end
    unless @numbers.size == 5 && @numbers.map(&:size).uniq == [5]
      raise "Wrong board size: #{@numbers.inspect}"
    end
    @marked = 5.times.map { 5.times.map { false } }
  end

  def won?
    @marked.any?(&:all?) || @marked.transpose.any?(&:all?)
  end

  def mark(num)
    5.times do |row|
      5.times do |column|
        @marked[row][column] ||= @numbers[row][column] == num
      end
    end
  end

  def unmarked_sum
    sum = 0
    5.times do |row|
      5.times do |column|
        sum += @numbers[row][column] unless @marked[row][column]
      end
    end
    sum
  end

  def score(num)
    unmarked_sum * num
  end

end

####################################################################

solve_with(Bingo, EXAMPLE => 4512) do |bingo|
  bingo.play.first
end

solve_with(Bingo, EXAMPLE => 1924) do |bingo|
  bingo.play.last
end
