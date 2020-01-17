'use strict';

/**
 * Configure the routes for CalCentral
 */
angular.module('calcentral.config').config(function($routeProvider) {
  // List all the routes
  $routeProvider.when('/', {
    templateUrl: 'splash.html',
    controller: 'SplashController',
    isPublic: true
  }).when('/academics', {
    templateUrl: 'academics.html',
    controller: 'AcademicsController',
    pageName: 'My Academics'
  }).when('/academics/academic_summary', {
    templateUrl: 'academic_summary_page.html',
    controller: 'AcademicSummaryController',
    pageName: 'My Academics'
  }).when('/academics/enrollment_verification', {
    templateUrl: 'academics_enrollment_verification.html',
    controller: 'EnrollmentVerificationController',
    pageName: 'My Enrollment Verification'
  }).when('/academics/exam_results', {
    templateUrl: 'exam_results_page.html',
    controller: 'ExamResultsController',
    pageName: 'Exam Results'
  }).when('/academics/graduation_checklist', {
    templateUrl: 'academics_graduation_checklist.html',
    controller: 'AcademicsController',
    pageName: 'Graduation Checklist'
  }).when('/academics/semester/:semesterSlug', {
    templateUrl: 'academics_semester.html',
    controller: 'AcademicsController',
    pageName: 'My Academics'
  }).when('/academics/semester/:semesterSlug/class/:classId', {
    templateUrl: 'academics_classinfo.html',
    controller: 'AcademicsController',
    pageName: 'My Academics'
  }).when('/academics/semester/:semesterSlug/class/:classId/:sectionSlug', {
    templateUrl: 'academics_classinfo.html',
    controller: 'AcademicsController',
    pageName: 'My Academics'
  }).when('/academics/booklist/:semesterSlug', {
    templateUrl: 'academics_booklist.html',
    controller: 'AcademicsController',
    pageName: 'My Academics'
  }).when('/academics/teaching-semester/:teachingSemesterSlug/class/:classId', {
    templateUrl: 'academics_classinfo.html',
    controller: 'AcademicsController',
    pageName: 'My Academics'
  }).when('/academics/teaching-semester/:teachingSemesterSlug/class/:classId/:category', {
    templateUrl: 'academics_classinfo.html',
    controller: 'AcademicsController',
    pageName: 'My Academics'
  }).when('/calcentral_update', {
    templateUrl: 'calcentral_update.html',
    controller: 'CalCentralUpdateController'
  }).when('/campus/:category?', {
    templateUrl: 'campus.html',
    controller: 'CampusController'
  }).when('/dashboard', {
    templateUrl: 'dashboard.html',
    controller: 'DashboardController',
    pageName: 'My Dashboard'
  }).when('/delegate_landing', {
    templateUrl: 'delegate_landing.html',
    controller: 'DelegateLandingController',
    isPublic: true
  }).when('/delegate_welcome', {
    templateUrl: 'delegate_welcome.html',
    controller: 'DelegateWelcomeController'
  }).when('/finances', {
    templateUrl: 'myfinances.html',
    controller: 'MyFinancesController',
    pageName: 'My Finances'
  }).when('/finances/details', {
    templateUrl: 'cars_details.html',
    controller: 'MyFinancesController',
    pageName: 'My Finances'
  }).when('/billing/details', {
    templateUrl: 'billing_details.html',
    controller: 'BillingDetailsController',
    pageName: 'My Finances'
  }).when('/finances/finaid/:finaidYearId?', {
    templateUrl: 'finaid.html',
    controller: 'MyFinancesController',
    pageName: 'Financial Aid and Scholarships'
  }).when('/finances/finaid/awards/:finaidYearId?', {
    templateUrl: 'finaid_awards_term.html',
    controller: 'MyFinancesController',
    pageName: 'Financial Aid and Scholarships'
  }).when('/finances/finaid/compare/:finaidYearId?', {
    templateUrl: 'award_comparison.html',
    controller: 'MyFinancesController',
    pageName: 'Award Comparison'
  }).when('/finances/cumulative_loan_debt', {
    templateUrl: 'cumulative_loan_debt_page.html',
    controller: 'LoanHistoryCumulativeController'
  }).when('/finances/loan_summary_aid_year', {
    templateUrl: 'loan_summary_by_aid_year_page.html',
    controller: 'LoanHistoryAidYearController'
  }).when('/finances/loan_resources', {
    templateUrl: 'loan_resources_page.html',
    controller: 'LoanHistoryResourcesController'
  }).when('/profile/:category?', {
    templateUrl: 'profile.html',
    controller: 'ProfileController',
    pageName: 'Profile'
  }).when('/toolbox', {
    templateUrl: 'toolbox.html',
    controller: 'MyToolboxController'
  }).when('/uid_error', {
    templateUrl: 'uid_error.html',
    controller: 'uidErrorController',
    isPublic: true
  }).when('/uid_slate_error', {
    templateUrl: 'uid_slate_error.html',
    controller: 'uidErrorController',
    isPublic: true
  }).when('/user/overview/:uid', {
    templateUrl: 'user_overview.html',
    controller: 'UserOverviewController',
    isAdvisingStudentLookup: true,
    pageName: 'Student Overview'
  });

  // Redirect to a 404 page
  $routeProvider.otherwise({
    templateUrl: '404.html',
    controller: 'ErrorController',
    isPublic: true
  });
});
