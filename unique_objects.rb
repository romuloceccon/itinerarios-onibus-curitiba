objects = []

STDIN.readlines.each do |line|
  line.strip!
  if m = line.match(/^(\d+),(\d+) \((\d+)\)$/)
    x, y, rank = m[1..3].map { |a| a.to_i }
    this = { x: x, y: y, rank: rank }
    
    found = false
    objects.each_with_index do |obj, i|
      if (obj[:x] - x).abs + (obj[:y] - y).abs <= 3
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
