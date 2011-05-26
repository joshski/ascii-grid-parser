class Cell
  attr_accessor :adjacent_cells, :contents

  def initialize(char)
    @contents = char
    @adjacent_cells = []
  end
  
end

class AsciiGrid
  
  def initialize(string)
    chars = string.split("")
    previous_cell = @origin = Cell.new(chars.shift)
    chars.each do |char| 
      new_cell = Cell.new(char)
      new_cell.adjacent_cells << previous_cell
      previous_cell.adjacent_cells << new_cell
      previous_cell = new_cell
    end
  end
  
  def origin
    @origin
  end
  
end

describe AsciiGrid do
  describe "when the source is a 'S'" do
    let :grid do
      AsciiGrid.new 'S'
    end

    it "originates in a cell with no adjacent cells" do
      grid.origin.should have(0).adjacent_cells
    end

    it "originates in a cell containing 'S'" do
      grid.origin.contents.should == 'S'
    end
    
    it "originates in a cell whose contents can be updated" do
      grid.origin.contents = 'Z'
      grid.origin.contents.should == 'Z'
    end
  end
  
  describe "when the source is a 'T" do
    let :grid do
      AsciiGrid.new 'T'
    end

    it "originates in a cell with no adjacent_cells" do
      grid.origin.should have(0).adjacent_cells
    end
      
    it "originates in a cell containing 'T'" do
      grid.origin.contents.should == 'T'
    end
    
  end

  describe "when the source is an 'SR'" do
    let :grid do
      AsciiGrid.new 'SR'
    end
    
    it "originates in a cell with one adjacent cell" do
      grid.origin.should have(1).adjacent_cells
    end
    
    it "originates in a cell containing 'S'" do
      grid.origin.contents.should == 'S'
    end
    
    it "originates in a cell adjacent to a cell containing 'R'" do
      grid.origin.adjacent_cells.first.contents.should == 'R'
    end
    
    it "originates in a cell which is adjacent to a cell which has 1 adjacent cell" do
      grid.origin.adjacent_cells.first.should have(1).adjacent_cells
    end
    
    it "originates in a cell which is adjacent to the origin" do
      grid.origin.contents = 'X'
      grid.origin.adjacent_cells.first.adjacent_cells.first.contents.should == 'X'
    end
    
  end
  
  describe "when the source is an 'ABC'" do
    let :grid do
      AsciiGrid.new 'ABC'
    end

    it "has a middle cell with 2 adjacent cells" do
      grid.origin.adjacent_cells.first.should have(2).adjacent_cells
    end
  end
end