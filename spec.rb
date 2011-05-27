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

shared_examples_for "parsing a single character" do
  let :origin do
    AsciiGrid.new.parse single_character
  end
  
  it "has no adjacent cells" do
    origin.should have(0).adjacent_cells
  end
  
  it "contains the single character" do
    origin.contents.should == single_character
  end
  
  it "has contents that can be updated" do
    origin.contents = 'Z'
    origin.contents.should == 'Z'
  end
  
  [:north, :south, :east, :west].each do |direction|
    it "has no cell to the #{direction}" do
      origin.send(direction).should be_nil
    end
  end
end

shared_examples_for "parsing two characters" do
  let :origin do
    AsciiGrid.new.parse two_characters
  end
  
  it "has one adjacent cell" do
    origin.should have(1).adjacent_cells
  end
  
  it "contains the first character" do
    origin.contents.should == two_characters.chars.first
  end
  
  it "is adjacent to a cell containing the second character" do
    origin.adjacent_cells.first.contents.should == two_characters.split('').last
  end
  
  it "is adjacent to a cell which has 1 adjacent cell" do
    origin.adjacent_cells.first.should have(1).adjacent_cells
  end
end

shared_examples_for "parsing two characters in a row" do
  let :origin do
    AsciiGrid.new.parse two_characters
  end
  
  it "has a cell to the east" do
    origin.east.contents.should == two_characters.chars.to_a[1]
  end
  
  it "has an eastern cell that has the origin to the west" do
    origin.east.west.should == origin
  end

  [:north, :south].each do |direction|
    it "has no cell to the #{direction}" do
      origin.send(direction).should be_nil
    end
    
    it "has a cell to the east with no cell to the #{direction}" do
      origin.east.send(direction).should be_nil
    end
  end
end

describe AsciiGrid do
  describe "parsing 'A'" do
    let :single_character do
      'A'
    end

    it_should_behave_like "parsing a single character"
  end
  
  describe "parsing 'B" do
    let :single_character do
      'B'
    end

    it_should_behave_like "parsing a single character"
  end

  describe "parsing 'CD'" do
    let :two_characters do
      'CD'
    end
    
    it_should_behave_like "parsing two characters"
    it_should_behave_like "parsing two characters in a row"
  end
  
  describe "parsing 'E\\nF'" do
    let :two_characters do
      "E\nF"
    end
    
    it_should_behave_like "parsing two characters"
  end
  
  describe "parsing 'GH\\nI'" do
    let :origin do
      AsciiGrid.new.parse "GH\nI"
    end
    
    it "has an origin with two adjacent cells" do
      origin.should have(2).adjacent_cells
    end
    
    it "has a cell to the east" do
      origin.east.contents.should == "H"
    end
    
    it "has a cell to the south" do
      origin.south.contents.should == "I"
    end
    
    it "has no cell to the south east" do
      origin.south.east.should be_nil
    end
  end
  
  describe "parsing 'J\\nKL'" do
    let :origin do
      AsciiGrid.new.parse "J\nKL"
    end
    
    it "has one adjacent cell" do
      origin.should have(1).adjacent_cells
    end
    
    it "has no cell to the east" do
      origin.east.should be_nil
    end
    
    it "has a cell to the south" do
      origin.south.contents.should == "K"
    end
    
    it "has a cell to the south east" do
      origin.south.east.contents.should == "L"
    end
  end
  
  describe "parsing 'MNO'" do
    let :origin do
      AsciiGrid.new.parse 'MNO'
    end

    it "has a middle cell with 2 adjacent cells" do
      origin.adjacent_cells.first.should have(2).adjacent_cells
    end
    
    it "has a middle cell with the origin to the west" do
      origin.east.west.should == origin
    end
  end
  
  describe "parsing 'PQ\\nRS'" do
    let :origin do
      AsciiGrid.new.parse "PQ\nRS"
    end

    it "returns to origin travelling east, south, west, north" do
      origin.east.south.west.north.should == origin
    end
    
    it "returns to origin travelling south, east, north, west" do
      origin.south.east.north.west.should == origin
    end
  end
end