describe GoogleApps::DriveManager do

  subject(:drive) { GoogleApps::DriveManager.new(random_id, random_id) }

  context 'unauthorized' do
    before do
      expect(GoogleApps::CredentialStore).to receive(:new).once.and_return (store = double)
      expect(Google::APIClient::Storage).to receive(:new).with(store).once.and_return (storage = double)
      expect(storage).to receive(:authorize).once.and_return nil
    end

    it 'should abort when OAuth2 tokens are not found' do
      expect{ drive.find_folders }.to raise_error /Failed to refresh Google OAuth tokens/
    end
  end

  context 'authorized' do
    let(:google_response_status) { 200 }
    let(:google_response) { double(status: google_response_status) }
    let(:google_api) { double(execute: google_response) }
    let(:drive_api) { double(files: double(list: double)) }

    before do
      allow(drive).to receive(:google_api).and_return google_api
      allow(drive).to receive(:drive_api).and_return drive_api
      allow(drive).to receive(:log_response)
    end

    context 'Google Drive operations' do
      context 'trash item' do
        let(:is_error) { false }
        let(:item) { double(id: double) }
        before do
          expect(google_response).to receive(:error?).and_return is_error
        end

        context 'error' do
          let(:is_error) { true }

          it 'should raise error when Google reports error' do
            expect(drive_api.files).to receive(:trash)
            expect{ drive.trash_item item }.to raise_error
          end
        end
        context 'delete or trash' do
          let(:data) { double }
          before do
            expect(google_response).to receive(:data).and_return data
          end

          it 'should permanently delete' do
            expect(drive_api.files).to receive(:delete)
            expect(drive.trash_item(item, permanently_delete: true)).to eq data
          end
          it 'should not permanently delete' do
            expect(drive_api.files).to receive(:trash)
            expect(drive.trash_item item).to eq data
          end
        end
      end
      context 'find folder by name' do
        let(:folder_title) { random_string(10) }
        let(:operation_type) { :list }
        context 'status 404' do
          let(:google_response_status) { 404 }
          it 'should return empty list' do
            expect(drive.find_folders_by_title folder_title).to eq []
          end
        end
        context 'status 500' do
          let(:google_response_status) { 500 }
          it 'should raise error' do
            expect{ drive.find_folders_by_title folder_title }.to raise_error
          end
        end
        context 'status 200' do
          before do
            rows.each do |row|
              expect(google_response).to receive(:data).once.ordered.and_return row
            end
          end
          context 'no results' do
            let(:rows) {
              [
                double(items: [], next_page_token: nil)
              ]
            }
            it 'should find folders' do
              expect(drive.find_folders_by_title folder_title).to eq []
            end
          end
          context 'results' do
            let(:rows) {
              [
                double(items: [ double, double ], next_page_token: random_id),
                double(items: [ double, double ], next_page_token: random_id),
                double(items: [ double ], next_page_token: nil)
              ]
            }
            it 'should find folders' do
              expect(drive.find_folders_by_title folder_title).to have(5).items
            end
          end
        end
      end
    end
  end
end
