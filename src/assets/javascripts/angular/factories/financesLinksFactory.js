'use strict';

/**
 * Finances Links Factory
 */
angular.module('calcentral.factories').factory('financesLinksFactory', function(apiService) {
  var urlEftEnrollment = '/api/my/eft_enrollment';
  var urlFppEnrollment = '/api/campus_solutions/fpp_enrollment';
  var urlEmergencyLoan = '/api/campus_solutions/financial_resources/emergency_loan';
  var urlSummerEstimator = '/api/campus_solutions/financial_resources/summer_estimator';

  var getEftEnrollment = function(options) {
    return apiService.http.request(options, urlEftEnrollment);
  };

  var getFppEnrollment = function(options) {
    return apiService.http.request(options, urlFppEnrollment);
  };

  var getEmergencyLoan = function(options) {
    return apiService.http.request(options, urlEmergencyLoan);
  };

  var getSummerEstimator = function(options) {
    return apiService.http.request(options, urlSummerEstimator);
  };

  return {
    getEftEnrollment: getEftEnrollment,
    getEmergencyLoan: getEmergencyLoan,
    getFppEnrollment: getFppEnrollment,
    getSummerEstimator: getSummerEstimator
  };
});
