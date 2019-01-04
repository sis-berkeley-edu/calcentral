'use strict';

/**
 * Financial Aid Terms and Conditions Factory
 */
angular.module('calcentral.factories').factory('termsAndConditionsFactory', function(apiService, $http) {
  var url = '/api/my/terms_and_conditions';
  var urlPostTC = '/api/campus_solutions/terms_and_conditions';

  var getTermsAndConditions = function(options) {
    return apiService.http.request(options, url +
      '/' + (options.finaidYear || '')
    );
  };

  var postTCResponse = function(finaidYearId, response) {
    return $http.post(urlPostTC, {
      aidYear: finaidYearId,
      response: response
    });
  };

  return {
    getTermsAndConditions: getTermsAndConditions,
    postTCResponse: postTCResponse
  };
});
