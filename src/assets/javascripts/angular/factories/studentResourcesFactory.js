'use strict';

var angular = require('angular');

/**
 * Student Resources Factory
 */
angular.module('calcentral.factories').factory('studentResourcesFactory', function(apiService) {
  var urlStudentResources = '/api/campus_solutions/student_resources';

  var getStudentResources = function(options) {
    return apiService.http.request(options, urlStudentResources);
  };

  return {
    getStudentResources: getStudentResources
  };
});
