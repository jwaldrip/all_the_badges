def stub_const_mock(const)

  mod = Module.new do
    extend self

    def self.__memo__
      @__memo__ ||= {}
    end

    def self.method_missing(m)
      __memo__[m] ||= self.dup.reset!
    end

    def self.const_missing(c)
      const_set c, self.dup
    end

    def reset!
      instance_variables.each { |v| remove_instance_variable v }
      self
    end
  end

  stub_const const, mod

end