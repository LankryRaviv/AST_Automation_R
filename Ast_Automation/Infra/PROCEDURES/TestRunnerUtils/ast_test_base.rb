load 'cosmos/tools/test_runner/test.rb'

class ASTCOSMOSTestHDRM < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestFSW < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestAOCS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestThermal < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestPower < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestCDH < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestPropulsion < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestMicron < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestCPBF < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestComm < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSTestCamera < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSThermalMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSHDRMMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSFSWMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSAOCSMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSPowerMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSCDHMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSPropulsionMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSMicronMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSCPBFMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class ASTCOSMOSCommMOPS < Cosmos::Test
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end
