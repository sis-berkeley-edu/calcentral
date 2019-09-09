'use strict';

/**
 * Finances Links Factory
 */
angular.module('calcentral.factories').factory('financesLinksFactory', function(apiService) {
  var urlEftEnrollment = '/api/my/eft_enrollment';
  var urlEmergencyLoan = '/api/campus_solutions/financial_resources/emergency_loan';
  var urlFinancialAidSummary = '/api/campus_solutions/financial_resources/financial_aid_summary';
  var urlSummerEstimator = '/api/campus_solutions/financial_resources/summer_estimator';
  var urlFppEnrollment = '/api/campus_solutions/fpp_enrollment';

  var getEftEnrollment = function(options) {
    return apiService.http.request(options, urlEftEnrollment);
  };

  var getEmergencyLoan = function(options) {
    return apiService.http.request(options, urlEmergencyLoan);
  };

  var getFppEnrollment = function(options) {
    return apiService.http.request(options, urlFppEnrollment);
  };

  var getFinancialAidSummary = function(options) {
    return apiService.http.request(options, urlFinancialAidSummary);
  };

  var getSummerEstimator = function(options) {
    return apiService.http.request(options, urlSummerEstimator);
  };

  return {
    getEftEnrollment: getEftEnrollment,
    getEmergencyLoan: getEmergencyLoan,
    getFinancialAidSummary: getFinancialAidSummary,
    getFppEnrollment: getFppEnrollment,
    getSummerEstimator: getSummerEstimator
  };
});
