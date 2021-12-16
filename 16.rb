require_relative './solve'

VERSION_SUM_EXAMPLES = {
  'D2FE28'                          => 6,
  '38006F45291200'                  => 9,
  'EE00D40C823060'                  => 14,
  '8A004A801A8002F478'              => 16,
  '620080001611562C8802118E34'      => 12,
  'C0015000016115A2E0802F182340'    => 23,
  'A0016C880162017C3686B18A3D4780'  => 31,
}

VALUE_EXAMPLES = {
  'C200B40A82'                  => 3,
  '04005AC33890'                => 54,
  '880086C3E88112'              => 7,
  'CE00C43D881120'              => 9,
  'D8005AC2A8F0'                => 1,
  'F600BC2D8F'                  => 0,
  '9C005AC2F8F0'                => 0,
  '9C0141080250320F1802104A08'  => 1,
}

class Packet

  def self.parse(hex)
    bits = hex.chars.map do |c|
      c.to_i(16).to_s(2).rjust(4, '0').chars
    end.flatten
    new(bits)
  end

  attr_reader :version, :type, :bits, :literal_value, :sub_packets

  def initialize(bits)
    @version = bits.shift(3).join.to_i(2)
    @type = bits.shift(3).join.to_i(2)
    @bits = bits

    @literal_value = consume_literal_value if literal_value?
    @sub_packets = Array((consume_sub_packets unless literal_value?))
  end

  def version_sum
    version + sub_packets.sum(&:version_sum)
  end

  def value
    case type
    when 0
      sub_packet_values.sum
    when 1
      sub_packet_values.reduce(&:*)
    when 2
      sub_packet_values.min
    when 3
      sub_packet_values.max
    when 4
      literal_value
    when 5
      sub_packet_values.reduce(&:>) ? 1 : 0
    when 6
      sub_packet_values.reduce(&:<) ? 1 : 0
    when 7
      sub_packet_values.reduce(&:==) ? 1 : 0
    end
  end

  private

  def literal_value?
    type == 4
  end

  def sub_packet_values
    sub_packets.map(&:value)
  end

  def consume_literal_value
    value = ''
    loop do
      start_bit, *group = bits.shift(5)
      value << group.join
      break if start_bit == '0'
    end
    value.to_i(2)
  end

  def consume_sub_packets
    length_type_id = bits.shift
    send("consume_sub_packets_type_#{length_type_id}")
  end

  def consume_sub_packets_type_0
    total_length = bits.shift(15).join.to_i(2)
    sub_packet_bits = bits.shift(total_length)
    [].tap do |a|
      until sub_packet_bits.empty?
        a << Packet.new(sub_packet_bits)
      end
    end
  end

  def consume_sub_packets_type_1
    num_packets_contained = bits.shift(11).join.to_i(2)
    Array.new(num_packets_contained) do
      Packet.new(bits)
    end
  end

end

solve_with_text(**VERSION_SUM_EXAMPLES) do |hex|
  Packet.parse(hex).version_sum
end

solve_with_text(**VALUE_EXAMPLES) do |hex|
  Packet.parse(hex).value
end
