module SpecHelperModule

  def suppress_rails_logging
    original_logger = Rails.logger
    begin
      Rails.logger = Logger.new("/dev/null")
      yield
    ensure
      Rails.logger = original_logger
    end
  end

  def stub_proxy(feed_method, stub_body)
    proxy = double()
    response = double()
    response.stub(:status).and_return(200)
    response.stub(:body).and_return(stub_body.to_json)
    proxy.stub(feed_method).and_return(response)
    proxy
  end

  def hub_edo_academic_status_student_plan(cpp_hash)
    value_defaults = {
      is_primary: true,
      type_code: 'MAJ',
      type_description: 'Major - Regular Acad/Prfnl',
      status_in_plan_action_code: 'MATR',
      status_in_plan_action_description: 'Matriculation',
      status_in_plan_status_code: 'AC',
      status_in_plan_status_description: 'Active in Program'
    }
    cpp_hash.reverse_merge!(value_defaults)
    adminOwners = cpp_hash[:admin_owners].to_a.collect do |owner|
      {
        "organization"=>{
          "code"=>owner[:org_code],
          "description"=>owner[:org_description]
        },
        "percentage"=>owner[:percentage]
      }
    end
    plan = {
      "academicPlan" => {
        "academicProgram" => {
          "program" => {
            "code" => cpp_hash[:program_code],
            "description" => cpp_hash[:program_description]
          },
          "academicCareer" => {
            "code" => cpp_hash[:career_code],
            "description" => cpp_hash[:career_description]
          }
        },
        "plan" => {
          "code" => cpp_hash[:plan_code],
          "description" => cpp_hash[:plan_description]
        },
        "type" => {
          "code" => cpp_hash[:type_code],
          "description" => cpp_hash[:type_description]
        },
        "ownedBy" => {
          "administrativeOwners" => adminOwners
        },
      },
      "primary" => cpp_hash[:is_primary],
      "statusInPlan" => {
        "action" => {
          "code" => cpp_hash[:status_in_plan_action_code],
          "description" => cpp_hash[:status_in_plan_action_description]
        },
        "reason" => {
          "code" => cpp_hash[:status_in_plan_reason_code],
          "description" => cpp_hash[:status_in_plan_reason_description]
        },
        "status" => {
          "code" => cpp_hash[:status_in_plan_status_code],
          "description" => cpp_hash[:status_in_plan_status_description]
        }
      }
    }
    if (cpp_hash[:expected_grad_term_id] && cpp_hash[:expected_grad_term_name])
      plan.merge!({
        "expectedGraduationTerm" => {
          "id" => cpp_hash[:expected_grad_term_id],
          "name" => cpp_hash[:expected_grad_term_name]
        }
      })
    end
    plan
  end

  def random_ccn
    sprintf('%05d', rand(99999))
  end

  def random_grade
    ['A', 'B', 'C'].sample + ['+', '-', ''].sample
  end

  def random_id
    rand(99999).to_s
  end

  def random_cs_id
    rand(9999999999).to_s
  end

  def random_name
    "#{random_string(6).capitalize} #{random_string(10).capitalize}"
  end

  def random_string(length)
    range = ('a'..'z').to_a
    length.times.map { range.sample }.join
  end

  def delete_files_if_exists(filepaths)
    filepaths.to_a.each do |filepath|
      File.delete(filepath) if File.exists?(filepath)
    end
  end

  def mock_google_drive_item(title='mock')
    double(id: "#{title}_id", title: title)
  end

  RSpec::Matchers.define :be_url do
    match do |actual|
      URI.parse(actual) rescue false
    end
  end

end
