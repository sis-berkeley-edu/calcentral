describe User::SearchUsersByNameFilter do
  let(:instance) { described_class.new }
  let(:name) { nil }
  subject { instance.prepare_for_query name }

  context 'when preparing a name for a SISEDO query' do

    context 'when a name is inputted' do
      let(:name) { 'Homer' }
      it 'converts the letters to uppercase' do
        expect(subject).to eq('HOMER')
      end
    end

    context 'when the name includes diacritics' do
      let(:name) { 'Ðéññïß' }
      it 'converts the diacritics to an alphabetical letter' do
        expect(subject).to eq('DENNISS')
      end
    end

    context 'when the name includes spaces' do
      let(:name) { 'The Big Kahuna' }
      it 'converts the spaces to wildcards' do
        expect(subject).to eq('THE%BIG%KAHUNA')
      end
    end

    context 'when a name includes special characters' do
      context 'if the characters are within the valid range of unicode characters' do
        context 'if the characters are katakana' do
          let (:name) { 'アイ・ラブ・ブロコリー' }
          it 'allows katakana' do
            expect(subject).to eq('アイ・ラブ・ブロコリー')
          end
        end

        context 'if the characters are hiragana' do
          let (:name) { 'ねにぬふむみま' }
          it 'allows hiragana' do
            expect(subject).to eq('ねにぬふむみま')
          end
        end

        context 'if the characters include CJK (Chinese, Japanese, Korean) characters' do
          let(:name) { '⺴〄》㌅㌊㐀㈵' }
          it 'allows CJK characters' do
            expect(subject).to eq('⺴〄》㌅㌊㐀㈵')
          end
        end
      end

      context 'if the characters are not within the valid range of unicode characters' do
        let(:name) { '!!$%%$$$#!!!' }
        it 'does not allow invalid characters' do
          expect(subject).to eq('')
        end
      end

      context 'if invalid characters are mixed with valid characters' do
        let(:name) { '!!$%にみまꀃꀆ' }
        it 'removes the invalid characters and leaves the valid ones' do
          expect(subject).to eq('にみま')
        end
      end
    end

  end
end
