'use strict';

/**
 * Advising Factory
 */
angular.module('calcentral.factories').factory('advisingFactory', function(apiService) {
  var urlAdvisingAcademics = '/api/advising/academics/';
  var urlAdvisingAcademicsCacheExpiry = '/api/advising/cache_expiry/academics/';
  var urlAdvisingCommittees = '/api/advising/student_committees/';
  var urlAdvisingDegreeProgressGraduate = '/api/advising/degree_progress/grad/';
  var urlAdvisingDegreeProgressUndergrad = '/api/advising/degree_progress/ugrd/';
  var urlAdvisingRegistrations = '/api/advising/registrations/';
  var urlAdvisingResources = '/api/advising/resources/';
  var urlAdvisingStudent = '/api/advising/student/';
  var urlAdvisingStudentSuccess = '/api/advising/student_success/';
  var urlResources = '/api/campus_solutions/advising_resources';

  // Dummy feeds
  // var urlAdvisingAcademics = '/dummy/json/advising_student_academics.json';
  // var urlAdvisingCommittees = '/dummy/json/advising_committees.json';
  // var urlAdvisingDegreeProgressGraduate = '/dummy/json/degree_progress_grad.json';
  // var urlAdvisingDegreeProgressUndergrad = '/dummy/json/degree_progress_ugrd.json';
  // var urlAdvisingRegistrations = 'dummy/json/advising_registrations.json';
  // var urlAdvisingResources = '/dummy/json/advising_resources.json';
  // var urlAdvisingStudent = '/dummy/json/advising_student_academics.json';
  // var urlAdvisingStudentSuccess = '/dummy/json/advising_student_success.json';
  // var urlResources = '/dummy/json/advising_resources.json';

  var getResources = function(options) {
    return apiService.http.request(options, urlResources);
  };

  var getAdvisingResources = function(options) {
    return apiService.http.request(options, urlAdvisingResources + options.uid);
  };

  var getStudent = function(options) {
    return apiService.http.request(options, urlAdvisingStudent + options.uid);
  };

  var getStudentAcademics = function(options) {
    return apiService.http.request(options, urlAdvisingAcademics + options.uid);
  };

  var getStudentRegistrations = function(options) {
    return apiService.http.request(options, urlAdvisingRegistrations + options.uid);
  };

  var getStudentSuccess = function(options) {
    return apiService.http.request(options, urlAdvisingStudentSuccess + options.uid);
  };

  var getDegreeProgressGraduate = function(options) {
    return apiService.http.request(options, urlAdvisingDegreeProgressGraduate + options.uid);
  };

  var getDegreeProgressUndergrad = function(options) {
    return apiService.http.request(options, urlAdvisingDegreeProgressUndergrad + options.uid);
  };

  var expireAcademicsCache = function(options) {
    return apiService.http.request(options, urlAdvisingAcademicsCacheExpiry + options.uid);
  };

  var getStudentCommittees = function(options) {
    return apiService.http.request(options, urlAdvisingCommittees + options.uid);
  };

  return {
    getAdvisingResources: getAdvisingResources,
    getResources: getResources,
    getStudent: getStudent,
    getStudentAcademics: getStudentAcademics,
    getStudentRegistrations: getStudentRegistrations,
    getStudentSuccess: getStudentSuccess,
    getDegreeProgressGraduate: getDegreeProgressGraduate,
    getDegreeProgressUndergrad: getDegreeProgressUndergrad,
    expireAcademicsCache: expireAcademicsCache,
    getStudentCommittees: getStudentCommittees
  };
});
