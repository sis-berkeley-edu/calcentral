'use strict';

var angular = require('angular');

/**
 * Student Attributes Factory
 */
angular.module('calcentral.factories').factory('studentAttributesFactory', function(apiService) {
  var urlStudentAttributes = '/dummy/json/hub_student_attributes.json';
  // var urlStudentAttributes = '/api/edos/student_attributes';

  var getStudentAttributes = function(options) {
    return apiService.http.request(options, urlStudentAttributes);
  };

  return {
    getStudentAttributes: getStudentAttributes
  };
});
