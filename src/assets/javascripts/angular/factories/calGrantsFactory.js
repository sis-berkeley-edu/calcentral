'use strict';

angular.module('calcentral.factories').factory('calGrantsFactory', function(apiService) {
  const url = '/api/my/calgrant_acknowledgements';

  const getCalGrants = function(options) {
    return apiService.http.request(options, url);
  };

  return { getCalGrants };
});
