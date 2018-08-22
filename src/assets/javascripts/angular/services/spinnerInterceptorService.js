'use strict';

angular.module('calcentral.services').factory('spinnerInterceptorService', function($q) {
  return {
    response: function(response) {
      // The data will be a string when it's a template that has been requested.
      if (angular.isObject(response.data)) {
        response.data.isLoading = false;
      }
      return response;
    },

    responseError: function(response) {
      // TODO we'll need to change this so we can show a valuable
      // message to the user when an error occurs
      // We can do this as soon as we get good error responses back from the server.
      if (angular.isObject(response.data)) {
        response.data.isLoading = false;
      } else {
        response.data = {
          isLoading: false
        };
      }
      return $q.reject(response);
    }
  };
});
