'use strict';

angular.module('calcentral.services').factory('httpErrorInterceptorService', function($q, errorService) {
  return {
    // Basic idea from http://stackoverflow.com/questions/11971213

    response: function(response) {
      return response;
    },

    responseError: function(response) {
      var status = response.status;

      if (status >= 400) {
        errorService.send('httpErrorInterceptorService - ' + response.status + ' - ' + response.config.url);
      }

      return $q.reject(response);
    }
  };
});
