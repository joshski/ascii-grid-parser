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

shared_examples_for "a grid with a single letter" do
  let :origin do
    AsciiGrid.new.parse single_letter
  end
  
  it "has an origin with no adjacent cells" do
    origin.should have(0).adjacent_cells
  end
  
  it "has an origin containing the single letter" do
    origin.contents.should == single_letter
  end
  
  it "has an origin whose contents can be updated" do
    origin.contents = 'Z'
    origin.contents.should == 'Z'
  end
  
  [:north, :south, :east, :west].each do |direction|
    it "has an origin with no cell to the #{direction}" do
      origin.send(direction).should be_nil
    end
  end
end

shared_examples_for "a grid with two letters" do
  let :origin do
    AsciiGrid.new.parse two_letters
  end
  
  it "has an origin with one adjacent cell" do
    origin.should have(1).adjacent_cells
  end
  
  it "has an origin containing the first letter" do
    origin.contents.should == two_letters.chars.first
  end
  
  it "has an origin adjacent to a cell containing the second letter" do
    origin.adjacent_cells.first.contents.should == two_letters.split('').last
  end
  
  it "has an origin which is adjacent to a cell which has 1 adjacent cell" do
    origin.adjacent_cells.first.should have(1).adjacent_cells
  end
end

shared_examples_for "a grid with two letters in a row" do
  let :origin do
    AsciiGrid.new.parse two_letters
  end
  
  it "has an origin with an adjacent cell to the east" do
    origin.east.contents.should == two_letters.chars.to_a[1]
  end
  
  it "has an origin with an eastern cell that has the origin to the west" do
    origin.east.west.should == origin
  end

  [:north, :south].each do |direction|
    it "has an origin with no cell to the #{direction}" do
      origin.send(direction).should be_nil
    end
    
    it "has a cell to the east with no cell to the #{direction}" do
      origin.east.send(direction).should be_nil
    end
  end
end

describe AsciiGrid do
  describe "when the source is 'A'" do
    let :single_letter do
      'A'
    end

    it_should_behave_like "a grid with a single letter"
  end
  
  describe "when the source is 'B" do
    let :single_letter do
      'B'
    end

    it_should_behave_like "a grid with a single letter"
  end

  describe "when the source is 'CD'" do
    let :two_letters do
      'CD'
    end
    
    it_should_behave_like "a grid with two letters"
    it_should_behave_like "a grid with two letters in a row"
  end
  
  describe "when the source is 'E\\nF'" do
    let :two_letters do
      "E\nF"
    end
    
    it_should_behave_like "a grid with two letters"
  end
  
  describe "when the source is 'GH\\nI'" do
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
  
  describe "when the source is 'J\\nKL'" do
    let :origin do
      AsciiGrid.new.parse "J\nKL"
    end
    
    it "has an origin with one adjacent cell" do
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
  
  describe "when the source is 'MNO'" do
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
  
  describe "when the source is 'PQ\\nRS'" do
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