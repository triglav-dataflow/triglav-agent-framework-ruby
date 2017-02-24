module StubConnection
  def self.included(klass)
    klass.extend(self)
  end

  def stub_connection
    obj = Object.new
    stub(Triglav::Agent::Base::Connection).new { obj }
  end
end
