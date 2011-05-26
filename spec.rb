class Cell
  attr_reader :adjacent_cells
  attr_accessor :contents

  def initialize(char, x, y, above, left)
    @contents = char
    @adjacent_cells = []
    add_adjacent_cell(above) if above
    add_adjacent_cell(left) if left
  end
  
  private
  
  def add_adjacent_cell(cell)
    @adjacent_cells << cell
    cell.adjacent_cells << self
    cell
  end
end

class AsciiGrid
  def initialize(string)
    rows = string.split("\n")
    cells = Array.new(rows.size)
    rows.each_with_index do |row, y|
      chars = row.split('')
      cells[y] = Array.new(chars.size)
      chars.each_with_index do |char, x| 
        above = y > 0 && cells[y-1][x]
        left  = x > 0 && cells[y][x-1]
        cells[y][x] = Cell.new(char, x, y, above, left)
      end
    end
    @origin = cells[0][0]
  end
  
  def origin
    @origin
  end
  
end

shared_examples_for "a grid with a single letter" do
  let :grid do
    AsciiGrid.new single_letter
  end
  
  it "originates in a cell with no adjacent cells" do
    grid.origin.should have(0).adjacent_cells
  end

  it "originates in a cell containing the single letter" do
    grid.origin.contents.should == single_letter
  end
  
  it "originates in a cell whose contents can be updated" do
    grid.origin.contents = 'Z'
    grid.origin.contents.should == 'Z'
  end
end

shared_examples_for "a grid with two letters" do
  let :grid do
    AsciiGrid.new two_letters
  end
  
  it "originates in a cell with one adjacent cell" do
    grid.origin.should have(1).adjacent_cells
  end
  
  it "originates in a cell containing the first letter" do
    grid.origin.contents.should == two_letters.chars.first
  end
  
  it "originates in a cell adjacent to a cell containing the second letter" do
    grid.origin.adjacent_cells.first.contents.should == two_letters.split('').last
  end
  
  it "originates in a cell which is adjacent to a cell which has 1 adjacent cell" do
    grid.origin.adjacent_cells.first.should have(1).adjacent_cells
  end
  
  it "originates in a cell which is adjacent to the origin" do
    grid.origin.contents = 'X'
    grid.origin.adjacent_cells.first.adjacent_cells.first.contents.should == 'X'
  end
  
end

describe AsciiGrid do
  describe "when the source is 'S'" do
    let :single_letter do
      'S'
    end

    it_should_behave_like "a grid with a single letter"
  end
  
  describe "when the source is 'T" do
    let :single_letter do
      'T'
    end

    it_should_behave_like "a grid with a single letter"
  end

  describe "when the source is 'SR'" do
    let :two_letters do
      'SR'
    end
    
    it_should_behave_like "a grid with two letters"
  end
  
  describe "when the source is 'F\\nG'" do
    let :two_letters do
      "F\nG"
    end
    
    it_should_behave_like "a grid with two letters"
  end
  
  describe "when the source is 'X\\nYZ'" do
    let :grid do
      AsciiGrid.new "XY\nZ"
    end
    
    it "has an origin with two adjacent cells" do
      grid.origin.should have(2).adjacent_cells
    end
  end
  
  describe "when the source is 'ABC'" do
    let :grid do
      AsciiGrid.new 'ABC'
    end

    it "has a middle cell with 2 adjacent cells" do
      grid.origin.adjacent_cells.first.should have(2).adjacent_cells
    end
  end
end