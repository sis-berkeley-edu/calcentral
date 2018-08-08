'use strict';



/**
 * POST to the Campus Solutions API which links delegate to a student account
 */
angular.module('calcentral.factories').factory('delegateFactory', function(apiService, $http) {
  var getStudentsURL = '/api/campus_solutions/delegate_access/students';
  var urlDelegateManagementURL = '/api/campus_solutions/delegate_management_url';
  var urlTermsAndConditions = '/api/campus_solutions/delegate_terms_and_conditions';
  var urlLinkAccounts = '/api/campus_solutions/delegate_access';

  var getStudents = function(options) {
    return apiService.http.request(options, getStudentsURL);
  };
  var getManageDelegatesURL = function(options) {
    return apiService.http.request(options, urlDelegateManagementURL);
  };
  var getTermsAndConditions = function(options) {
    return apiService.http.request(options, urlTermsAndConditions);
  };
  var linkAccounts = function(options) {
    return $http.post(urlLinkAccounts, options);
  };

  return {
    getManageDelegatesURL: getManageDelegatesURL,
    getStudents: getStudents,
    getTermsAndConditions: getTermsAndConditions,
    linkAccounts: linkAccounts
  };
});
