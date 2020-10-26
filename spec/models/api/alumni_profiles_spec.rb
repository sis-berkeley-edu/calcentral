describe Api::AlumniProfiles do

  subject { described_class.new('123') }

  let (:feed_data) do
    {
      landing_page_sub_title: 'card title',
      landing_page_message:  'overlay msg',
      homepage_link: 'link',
      skip_landing_page: false
    }
  end

  before do
    allow(AlumniProfile).to receive(:find_by).with(any_args).and_return({uid: '123'})
    allow(described_class).to receive(:landing_page_sub_title).and_return(feed_data[:landing_page_sub_title])
    allow(described_class).to receive(:landing_page_message).and_return(feed_data[:landing_page_message])
    allow(described_class).to receive(:homepage_link).and_return(feed_data[:homepage_link])
  end

  it 'should return alumni profile feed' do
    expect(subject.get_feed_internal).to eq feed_data
  end

end
