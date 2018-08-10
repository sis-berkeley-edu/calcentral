describe Webcast::Recordings do

  let(:use_legacy_ccns) { true }
  before do
    allow(Settings.features).to receive(:allow_legacy_fallback).and_return(use_legacy_ccns)
  end

  context 'a fake proxy' do
    let(:recordings) { Webcast::Recordings.new(fake: true).get }
    context 'when integrating with an SIS source which understands legacy CCNs' do
      it 'should return many playlists' do
        expect(recordings[:courses]).to have(25).items
        law_2723 = recordings[:courses]['2008-D-49688']
        expect(law_2723).to_not be_nil
        expect(law_2723[:youtube_playlist]).to eq 'EC8DA9DAD111EAAD28'
        expect(law_2723[:recordings]).to have(12).items
      end
    end
    context 'when integrating with a CS-only SIS source which lacks legacy CCNs' do
      let(:use_legacy_ccns) { false }
      # Currently, only 3 of the 25 courses in the fake JSON feed are CS-era.
      # This test code only stubs legacy-CCN translations for 2 courses,
      # which means the other 23 legacy courses should have nil CS Section ID
      # values and be stripped out of the final parsed feed.
      before do
        allow(Berkeley::LegacyTerms).to receive(:legacy_ccns_to_section_ids) do |cs_term_id, legacy_ccns|
          expect(cs_term_id).to be < '2168'
          if cs_term_id == '2142'
            expect(legacy_ccns).to include('71859', '74163')
            {'71859' => '66671859', '74163' => '66674163'}
          else
            {}
          end
        end
      end
      it 'returns CS-mapped playlists' do
        expect(recordings[:courses]).to have(5).items
        ['2014-B-66671859', '2014-B-66671859'].each do |legacy_key|
          course_captures = recordings[:courses][legacy_key]
          expect(course_captures[:youtube_playlist]).to be_present
          expect(course_captures[:recordings]).to be_present
        end
      end
    end
  end
end
