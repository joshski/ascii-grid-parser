class Cell
  attr_accessor :contents, :north, :south, :east, :west

  def initialize(char, x, y)
    @contents = char
  end
  
  def adjacent_cells
    [north, south, east, west].compact
  end
end

class MapBuilder
  def cell(char, x, y)
    Cell.new(char, x, y)
  end
  
  def east_west(east, west)
    east.west = west if east
    west.east = east if west
  end
  
  def north_south(north, south)
    north.south = south if north
    south.north = north if south
  end
end

class AsciiGrid
  def initialize(builder=MapBuilder.new)
    @builder = builder
  end
  
  def parse(string)
    rows = string.split("\n")
    cells = Array.new(rows.size)
    rows.each_with_index do |row, y|
      chars = row.split('') 
      cells[y] = Array.new(chars.size)
      chars.each_with_index do |char, x| 
        cells[y][x] = cell = @builder.cell(char, x, y)
        @builder.north_south(cells[y-1][x], cell) if y > 0
        @builder.east_west(cell, cells[y][x-1]) if x > 0
      end
    end
    cells[0][0]
  end
end
