describe BackgroundableShim do

  before do
    allow(Settings).to receive(:background_torquebox).and_return(use_torquebox)
  end
  context 'with Torquebox' do
    let(:use_torquebox) { true }
    it 'supports Torquebox background jobs' do
      class Toxed
        include BackgroundableShim
      end
      shimmed = Toxed.new
      expect(shimmed.background.class).to eq TorqueBox::Messaging::Backgroundable::BackgroundProxy
      expect(Toxed.respond_to? :always_background).to be_truthy
    end
  end
  context 'without Torquebox' do
    let(:use_torquebox) { false }
    it 'still backgrounds' do
      class Detoxed
        include BackgroundableShim
      end
      shimmed = Detoxed.new
      expect(shimmed.is_a? BackgroundThread).to be_truthy
    end
  end

end
