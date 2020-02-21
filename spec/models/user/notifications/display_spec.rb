describe User::Notifications::Display do
  subject { User::Notifications::Display.new('fake-uid') }

  def days_ago_string(count)
    count.days.ago.beginning_of_day.in_time_zone.to_s
  end

  def days_from_now_string(count)
    count.days.from_now.beginning_of_day.in_time_zone.to_s
  end

  describe "#display_all?" do
    describe "with no data returned from the query" do
      it "returns false" do
        expect(subject).to receive(:data).and_return(nil)
        expect(subject).not_to be_display_all
      end
    end

    describe "with data returned" do
      describe 'should_display_all = "Y"' do
        describe "without expiration date" do
          it "should display all" do
            expect(subject).to receive(:data).and_return({
              'display_all_expires' => nil,
              'should_display_all' => 'Y'
            }).at_least(:once)

            expect(subject).to be_display_all
          end
        end

        describe "before the expiration date" do
          it "should display_all?" do
            expect(subject).to receive(:data).and_return({
              'display_all_expires' => days_from_now_string(1),
              'should_display_all' => 'Y'
            }).at_least(:once)

            expect(subject).to be_display_all
          end
        end

        describe "past the expiration date" do
          it "should not display_all?" do
            expect(subject).to receive(:data).and_return({
              'display_all_expires' => days_ago_string(1),
              'should_display_all' => 'Y'
            }).at_least(:once)

            expect(subject).not_to be_display_all
          end
        end
      end

      it 'should_display_all = "N"' do
        expect(subject).to receive(:data).and_return({
          'display_all_expires' => nil,
          'should_display_all' => 'N'
        }).at_least(:once)

        expect(subject).not_to be_display_all
      end
    end
  end
end
