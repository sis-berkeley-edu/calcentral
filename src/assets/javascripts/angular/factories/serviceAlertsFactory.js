'use strict';

/**
 * Blog Factory
 */
angular.module('calcentral.factories').factory('serviceAlertsFactory', function(apiService) {
  var url = '/api/service_alerts';

  var getAlerts = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getAlerts: getAlerts
  };
});
