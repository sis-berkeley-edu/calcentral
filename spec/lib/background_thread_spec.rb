describe BackgroundThread do
  class TestClass
    include BackgroundThread
    def fiddle(stick, suffix)
      Rails.cache.write("fiddle_#{stick}", "#{self.class.name}-#{suffix}")
      return 'Not a future'
    end
    def time_bomb(seconds)
      bg_run do
        sleep seconds
        raise ArgumentError.new('Snark must not be Boojum')
      end
    end
  end

  subject { TestClass.new }

  it 'does not directly return if backgrounded' do
    report = subject.fiddle('foreground', 1)
    expect(report).to eq 'Not a future'
    expect(Rails.cache.read('fiddle_foreground')).to eq 'TestClass-1'
    report = subject.background.fiddle('background', 2)
    expect(report).to eq true
    sleep(1)
    expect(Rails.cache.read('fiddle_background')).to eq 'TestClass-2'
  end

  it 'logs uncaught exceptions instead of silently dropping the task' do
    expect(Rails.logger).to receive(:error) do |error_message|
      lines = error_message.lines.to_a
      expect(lines[0]).to match(/Boojum/)
    end
    report = subject.time_bomb 1
    expect(report).to eq true
    sleep 2
  end

end
