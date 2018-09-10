'use strict';

/**
 * Cal1Card Factory
 */
angular.module('calcentral.factories').factory('cal1CardFactory', function(apiService) {
  var url = '/api/my/cal1card';
  // var url = '/dummy/json/cal1card.json';
  // var url = '/dummy/json/cal1card-lost.json';
  // var url = '/dummy/json/cal1card-found.json';

  var getCal1Card = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getCal1Card: getCal1Card
  };
});
