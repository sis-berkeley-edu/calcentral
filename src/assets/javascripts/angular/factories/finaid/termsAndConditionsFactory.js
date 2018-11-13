'use strict';

/**
 * Financial Aid Terms and Conditions Factory
 */
angular.module('calcentral.factories').factory('termsAndConditionsFactory', function(apiService) {
  var url = '/api/my/terms_and_conditions';

  var getTermsAndConditions = function(options) {
    return apiService.http.request(options, url +
      '/' + (options.finaidYear || '')
    );
  };

  return {
    getTermsAndConditions: getTermsAndConditions
  };
});
