'use strict';

var angular = require('angular');

/**
 * Academic Status Factory
 */
angular.module('calcentral.factories').factory('academicStatusFactory', function(apiService, $route, $routeParams) {
  // var urlAcademicStatus = '/dummy/json/hub_academic_status.json';
  var urlAcademicStatus = '/api/edos/academic_status';
  var urlAdvisingAcademicStatus = '/api/advising/academic_status/';

  var getAcademicStatus = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingAcademicStatus + $routeParams.uid : urlAcademicStatus;
    return apiService.http.request(options, url);
  };

  return {
    getAcademicStatus: getAcademicStatus
  };
});
