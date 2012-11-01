objects = []

STDIN.readlines.each do |line|
  line.strip!
  if m = line.match(/^(\d+),(\d+) \((\d+)\)$/)
    x, y, rank = m[1..3].map { |a| a.to_i }
    this = { x: x, y: y, rank: rank }
    
    found = false
    objects.each_with_index do |obj, i|
      dist = (obj[:x] - x).abs + (obj[:y] - y).abs
      rank_ratio = rank < obj[:rank] ? rank * 1.0 / obj[:rank] : obj[:rank] * 1.0 / rank
      if dist <= 3 || dist <= 10 && rank_ratio < 0.8
        found = true
        objects[i] = this if rank > obj[:rank]
        break
      end
    end
    objects << this unless found
  end
end

objects.each do |obj|
  puts "#{obj[:x]},#{obj[:y]} (#{obj[:rank]})"
end

STDERR.puts "filtered_count=#{objects.count}"
