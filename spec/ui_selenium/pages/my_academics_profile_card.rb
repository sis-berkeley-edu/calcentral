module CalCentralPages

  class MyAcademicsProfileCard < MyAcademicsPage

    div(:profile_card, :xpath => '//div[@data-ng-if="api.user.profile.hasStudentHistory || api.user.profile.roles.student || api.user.profile.roles.applicant"]')
    div(:term_transition_msg, :class => 'cc-widget-profile-message-text')
    h3(:term_transition_heading, :xpath => '//h3[contains(text(),"Academic status as of")]')
    div(:name, :xpath => '//div/strong[@data-ng-bind="api.user.profile.fullName"]')
    button(:show_gpa, :xpath => '//button[text()="Show GPA"]')
    button(:hide_gpa, :xpath => '//button[text()="Hide"]')
    div(:gpa, :xpath => '//strong[@data-ng-bind="gpaUnits.cumulativeGpaFloat"]')
    elements(:college, :div, :xpath => '//div[@data-ng-bind="major.college"]')
    elements(:major, :div, :xpath => '//strong[@data-ng-bind="major.major"]')
    elements(:career, :td, :xpath => '//div[@data-ng-repeat="career in collegeAndLevel.careers"]/strong')
    td(:units, :xpath => '//td/strong[@data-ng-bind="gpaUnits.totalUnits"]')
    td(:level, :xpath => '//td/strong[@data-ng-bind="collegeAndLevel.level"]')
    td(:level_non_ap, :xpath => '//td/strong[@data-ng-bind="collegeAndLevel.nonApLevel"]')
    div(:non_reg_student_msg, :xpath => '//div[contains(text(), "You are not registered as a student")]')
    div(:ex_student_msg, :xpath => '//div[contains(text(),"You are not currently considered an active student.")]')
    div(:reg_no_standing_msg, :xpath => '//div[contains(text(),"You are registered as a student, but complete profile information is not available.")]')
    span(:new_student_msg, :xpath => '//span[contains(text(),"More information will display here when your academic status changes.")]')
    div(:concur_student_msg, :xpath => '//div[contains(text(),"You are a concurrent enrollment student.")]')
    link(:uc_ext_link, :xpath => '//a[contains(text(),"UC Berkeley Extension")]')
    link(:eap_link, :xpath => '//a[contains(text(),"Berkeley International Office")]')

    def all_colleges
      colleges = []
      college_elements.each { |college| colleges << college.text }
      colleges
    end

    def all_majors
      majors = []
      major_elements.each { |major| majors << major.text }
      majors
    end

    def all_careers
      careers = []
      career_elements.each { |career| careers << career.text }
      careers
    end

  end
end
