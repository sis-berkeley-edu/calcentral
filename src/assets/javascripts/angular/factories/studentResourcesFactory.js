'use strict';

var angular = require('angular');

/**
 * Student Resources Factory
 */
angular.module('calcentral.factories').factory('studentResourcesFactory', function(apiService) {
  var urlStudentResources = '/api/campus_solutions/student_resources';
  // var urlStudentResources = '/dummy/json/student_resources.json';

  var getStudentResources = function(options) {
    return apiService.http.request(options, urlStudentResources);
  };

  return {
    getStudentResources: getStudentResources
  };
});
