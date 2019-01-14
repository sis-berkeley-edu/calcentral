'use strict';

/**
 * Financial Aid Terms and Conditions Factory
 */
angular.module('calcentral.factories').factory('title4Factory', function(apiService, $http) {
  var url = '/api/my/title4';
  var urlPostT4 = '/api/campus_solutions/title4';

  var getTitle4 = function(options) {
    return apiService.http.request(options, url);
  };

  var postT4Response = function(response) {
    return $http.post(urlPostT4, {
      response: response
    });
  };

  return {
    getTitle4: getTitle4,
    postT4Response: postT4Response
  };
});
