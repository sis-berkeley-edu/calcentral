'use strict';

var angular = require('angular');

/**
 * Finances Links Factory
 */
angular.module('calcentral.factories').factory('financesLinksFactory', function(apiService) {
  var urlEftEnrollment = '/api/my/eft_enrollment';
  var urlFppEnrollment = '/api/campus_solutions/fpp_enrollment';
  var urlGeneralCsLinks = '/api/campus_solutions/financial_resources_general';
  var urlSummerEstimator = '/api/campus_solutions/financial_resources_parameterized/summer_estimator/';

  var getEftEnrollment = function(options) {
    return apiService.http.request(options, urlEftEnrollment);
  };

  var getFppEnrollment = function(options) {
    return apiService.http.request(options, urlFppEnrollment);
  };

  var getGeneralCsLinks = function(options) {
    return apiService.http.request(options, urlGeneralCsLinks);
  };

  var getSummerEstimator = function(options) {
    urlSummerEstimator = options && options.aidYear ? urlSummerEstimator + options.aidYear : urlSummerEstimator;
    return apiService.http.request(options, urlSummerEstimator);
  };

  return {
    getGeneralCsLinks: getGeneralCsLinks,
    getEftEnrollment: getEftEnrollment,
    getFppEnrollment: getFppEnrollment,
    getSummerEstimator: getSummerEstimator
  };
});
