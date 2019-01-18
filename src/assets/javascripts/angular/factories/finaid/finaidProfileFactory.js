'use strict';

/**
 * Financial Aid Profile Factory
 */
angular.module('calcentral.factories').factory('finaidProfileFactory', function(apiService) {
  var url = '/api/my/finaid_profile';

  var getFinaidProfile = function(options) {
    return apiService.http.request(options, url +
      '/' + (options.finaidYear || '')
    );
  };

  return {
    getFinaidProfile: getFinaidProfile
  };
});
