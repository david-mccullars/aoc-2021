require_relative './solve'

EXAMPLE = <<-END
#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########
END

ROOMS = 4
HALLWAY_SIZE = 11
AMPHIPOD_MOVE_COSTS = [1, 10, 100, 1_000]
ILLEGAL_HALLWAY_POSITIONS = [2, 4, 6, 8]

require 'erb'
AmphipodsState = {}
[2, 4].each do |amphipods_per_room|
  erb = File.read(File.expand_path('23_amphipods_state.rb.erb', __dir__))
  AmphipodsState[amphipods_per_room] = eval ERB.new(erb).result(binding)
end

class AmphipodsSolver

  def initialize(text)
    @input = text.scan(/[A-Z]/)
  end

  def unfold_extra_input(*extra)
    mid = @input.size / 2
    @input = @input[0...mid] + extra + @input[mid..]
  end

  def amphipods_state_class
    raise "Input size is not a multiple of #{ROOMS}" unless @input.size % ROOMS == 0
    AmphipodsState[@input.size / ROOMS] or raise "Input size invalid: #{@input.size}"
  end

  def initial_state
    state = Array.new(ROOMS) { Set.new }
    @input.each_slice(ROOMS).to_a.transpose.flatten.each_with_index do |a, idx|
      state[a.ord - 'A'.ord] << HALLWAY_SIZE + idx
    end
    amphipods_state_class.new(state)
  end

  def finished_state
    amphipods_state_class::FINISHED_STATE
  end

  def minimum_energy
    DijkstraFast.shortest_distance(initial_state, finished_state, progress: true, connections: :legal_moves)
  end

end

solve_with(AmphipodsSolver, :text, EXAMPLE => 12521) do |solver|
  solver.minimum_energy
end

solve_with(AmphipodsSolver, :text, EXAMPLE => 44169) do |solver|
  solver.unfold_extra_input(
    'D', 'C', 'B', 'A',
    'D', 'B', 'A', 'C',
  )
  solver.minimum_energy
end
