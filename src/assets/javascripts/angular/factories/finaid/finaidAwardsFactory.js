'use strict';

/**
 * Awards Factory
 */
angular.module('calcentral.factories').factory('finaidAwardsFactory', function(apiService) {
  var url = '/api/my/awards/';

  var getAwards = function(options) {
    return apiService.http.request(options, url + options.finaidYearId);
  };

  return {
    getAwards: getAwards
  };
});
