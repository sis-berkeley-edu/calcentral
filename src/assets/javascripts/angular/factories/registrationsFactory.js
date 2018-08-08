'use strict';



/**
 * Registrations Factory
 */
angular.module('calcentral.factories').factory('registrationsFactory', function(apiService) {
  var url = '/api/my/registrations';
  // var url = '/dummy/json/my_registrations.json'

  var getRegistrations = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getRegistrations: getRegistrations
  };
});
