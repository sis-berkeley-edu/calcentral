'use strict';

var angular = require('angular');

/**
 * Student Attributes Factory
 */
angular.module('calcentral.factories').factory('studentAttributesFactory', function(apiService, $route, $routeParams) {
  // var urlStudentAttributes = '/dummy/json/hub_student_attributes.json';
  var urlAdvisingStudentAttributes = '/api/advising/student_attributes/';
  var urlStudentAttributes = '/api/edos/student_attributes';

  var getStudentAttributes = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingStudentAttributes + $routeParams.uid : urlStudentAttributes;
    return apiService.http.request(options, url);
  };

  return {
    getStudentAttributes: getStudentAttributes
  };
});
