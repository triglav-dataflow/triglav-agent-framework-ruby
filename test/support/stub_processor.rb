module StubProcessor
  def self.included(klass)
    klass.extend(self)
  end

  def stub_processor
    stub.proxy(Triglav::Agent::Base::Processor).new do |obj|
      stub(obj).total_count { 1 }
      stub(obj).process { 1 }
    end
  end
end
