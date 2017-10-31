'use strict';

var angular = require('angular');

/**
 * Academics Factory
 */
angular.module('calcentral.factories').factory('academicsFactory', function(apiService) {
  var url = '/api/my/academics';
  // var url = '/dummy/json/academics.json';

  var urlResidency = '/api/my/residency';
  // var urlResidency = '/dummy/json/residency.json';

  var getAcademics = function(options) {
    return apiService.http.request(options, url);
  };

  var getResidency = function(options) {
    return apiService.http.request(options, urlResidency);
  };

  return {
    getAcademics: getAcademics,
    getResidency: getResidency
  };
});
