class Cell

  def initialize(char,adjacent_cells=[])
    @char = char
    @adjacent_cells = adjacent_cells
  end
  
  def adjacent_cells
    @adjacent_cells
  end
  
  def contents
    @char
  end
  
end

class AsciiGrid
  
  def initialize(chars)
    @chars = chars
  end
  
  def origin
    Cell.new(@chars, Array.new(@chars.length - 1))
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
    
  end
end