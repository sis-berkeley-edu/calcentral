'use strict';



/**
 * Housing Factory
 */
angular.module('calcentral.factories').factory('housingFactory', function(apiService) {
  var url = '/api/my/housing/';

  var getHousing = function(options) {
    return apiService.http.request(options, url + options.aidYear);
  };

  return {
    getHousing: getHousing
  };
});
