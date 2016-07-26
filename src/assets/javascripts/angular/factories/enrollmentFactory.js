'use strict';

var angular = require('angular');

/**
 * Factory for the enrollment information.
 * The second set of URLs relate to Advisors doing student lookup, NOT a view-as mode.
 */
angular.module('calcentral.factories').factory('enrollmentFactory', function(apiService, $route, $routeParams) {
  // var urlAcademicPlan = '/dummy/json/academic_plan.json';
  var urlAcademicPlan = '/api/campus_solutions/academic_plan';
  // var urlEnrollmentTerm = '/dummy/json/enrollment_term.json';
  var urlEnrollmentTerm = '/api/campus_solutions/enrollment_term';
  // var urlEnrollmentTerms = '/dummy/json/enrollment_terms.json';
  var urlEnrollmentTerms = '/api/campus_solutions/enrollment_terms';

  // var urlAdvisingAcademicPlan = '/dummy/json/academic_plan.json';
  var urlAdvisingAcademicPlan = '/api/advising/academic_plan/';
  // var urlAdvisingEnrollmentTerm = '/dummy/json/enrollment_term.json';
  var urlAdvisingEnrollmentTerm = '/api/advising/enrollment_term/';
  // var urlAdvisingEnrollmentTerms = '/dummy/json/enrollment_terms.json';
  var urlAdvisingEnrollmentTerms = '/api/advising/enrollment_terms/';

  var getAcademicPlan = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingAcademicPlan + $routeParams.uid : urlAcademicPlan;
    return apiService.http.request(options, url);
  };
  var getEnrollmentTerm = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingEnrollmentTerm + $routeParams.uid : urlEnrollmentTerm;
    return apiService.http.request(options, url + '?term_id=' + options.termId);
  };
  var getEnrollmentTerms = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingEnrollmentTerms + $routeParams.uid : urlEnrollmentTerms;
    return apiService.http.request(options, url);
  };

  return {
    getAcademicPlan: getAcademicPlan,
    getEnrollmentTerm: getEnrollmentTerm,
    getEnrollmentTerms: getEnrollmentTerms
  };
});
