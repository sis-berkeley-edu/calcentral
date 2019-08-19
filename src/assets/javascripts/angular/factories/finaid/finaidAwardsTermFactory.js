'use strict';

/**
 * Awards By Term Factory
 */
angular.module('calcentral.factories').factory('finaidAwardsByTermFactory', function(apiService) {
  var url = '/api/my/awards_by_term/';

  var getAwardsByTerm = function(options) {
    return apiService.http.request(options, url + options.finaidYearId);
  };

  return {
    getAwardsByTerm: getAwardsByTerm
  };
});
