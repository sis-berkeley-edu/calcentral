'use strict';

/**
 * Financial Aid Terms and Conditions Factory
 */
angular.module('calcentral.factories').factory('title4Factory', function(apiService) {
  var url = '/api/my/title4';

  var getTitle4 = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getTitle4: getTitle4
  };
});
