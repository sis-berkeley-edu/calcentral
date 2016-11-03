describe GoogleApps::SheetsManager do

  context '#real', testext: true, order: :defined do
    before(:all) do
      # Google OAuth2
      @app_id = GoogleApps::Proxy::OEC_APP_ID
      @uid = Settings.oec.google.uid
      refresh_token = Settings.oec.google.testext.refresh_token
      raise ArgumentError, 'testext.local.yml is missing config: oec.google.testext.refresh_token' if refresh_token.blank?
      GoogleApps::CredentialStore.new(@app_id, @uid).write('expired-access-token', refresh_token)

      # Aw sheets!
      now = DateTime.now.strftime '%m/%d/%Y at %I:%M%p'
      @sheets = GoogleApps::SheetsManager.new(@app_id, @uid)
      @folder = @sheets.create_folder "#{GoogleApps::SheetsManager.name} test, #{now}"
      @spreadsheet_title = "Sheet from CSV, #{now}"
      @worksheet_title = "Primary worksheet, #{now}"
      # No CSV files will be created by this test
      @sis_import_sheet = Oec::SisImportSheet.new(dept_code: 'LPSPP')
      course_codes = [
        Oec::CourseCode.new(
          dept_name: 'SPANISH',
          catalog_id: '',
          dept_code: 'LPSPP',
          include_in_oec: true)
      ]
      Oec::SisImportTask.new(term_code: '2014-C').import_courses(@sis_import_sheet, course_codes)
      @spreadsheet = @sheets.upload_to_spreadsheet(@spreadsheet_title, @sis_import_sheet.to_io, @folder.id, @worksheet_title)
    end

    after(:all) do
      @sheets.trash_item(@folder, permanently_delete: true) if @folder
      User::Oauth2Data.where(app_id: @app_id, uid: @uid).delete_all
    end

    context 'spreadsheets' do
      it 'should upload csv to spreadsheet in target folder' do
        expect(@spreadsheet).to_not be_nil
      end

      it 'should get spreadsheet by id' do
        sheet_by_id = @sheets.spreadsheet_by_id @spreadsheet.id
        expect(sheet_by_id).to_not be nil
        spreadsheets = @sheets.spreadsheets_by_title @spreadsheet_title
        expect(spreadsheets).to have(1).item
        sheet_by_title = spreadsheets[0]
        expect(sheet_by_title).to_not be nil
        # Arbitrary comparison
        expect(sheet_by_id.worksheets[0][2, 2]).to eq sheet_by_title.worksheets[0][2, 2]
      end

      it 'should output the same CSV values that were put in' do
        spreadsheet_file = @sheets.find_items(parent_id: @folder.id).first
        csv_export = @sheets.export_csv spreadsheet_file
        parsed_csv = CSV.parse csv_export
        expect(parsed_csv[0]).to eq @sis_import_sheet.headers
        @sis_import_sheet.each_sorted_with_index do |row, i|
          expect(parsed_csv[i+1][0]).to eq row['COURSE_ID']
          expect(parsed_csv[i+1][@sis_import_sheet.headers.index('EVALUATION_TYPE')]).to eq row['EVALUATION_TYPE']
        end
      end

      it 'should update cells in batch' do
        spreadsheet_file = @sheets.find_items(parent_id: @folder.id).first
        worksheet = @sheets.spreadsheet_by_id(@spreadsheet.id).worksheets.first
        @sheets.update_worksheet(worksheet, {
          [2, 2] => 'Kilroy',
          [2, 3] => 'was',
          [4, 4] => 'here'
        })
        csv_export = @sheets.export_csv spreadsheet_file
        parsed_csv = CSV.parse csv_export
        # The CSV export is indexed from zero, but the Sheets API is indexed from one.
        expect(parsed_csv[1][1]).to eq 'Kilroy'
        expect(parsed_csv[1][2]).to eq 'was'
        expect(parsed_csv[3][3]).to eq 'here'
        # Other cells are unmodified.
        @sis_import_sheet.each_sorted_with_index do |row, i|
          expect(parsed_csv[i+1][0]).to eq row['COURSE_ID']
        end
      end

      it 'should have named the worksheet as well as the Sheets file' do
        worksheet = @sheets.spreadsheet_by_id(@spreadsheet.id).worksheets.first
        expect(worksheet.title).to eq @worksheet_title
      end

      it 'should find no spreadsheet mapped to bogus id' do
        sheet_by_id = @sheets.spreadsheet_by_id 'bogus-id'
        expect(sheet_by_id).to be_nil
      end

      it 'should find no spreadsheets with bogus title' do
        spreadsheets = @sheets.spreadsheets_by_title 'let us hope that no spreadsheets have this ridiculous name'
        expect(spreadsheets).to be_empty
      end
    end

  end
end
