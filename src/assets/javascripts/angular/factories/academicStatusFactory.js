'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Academic Status Factory
 */
angular.module('calcentral.factories').factory('academicStatusFactory', function(apiService, $route, $routeParams) {
  var urlAcademicStatus = '/api/edos/academic_status';
  // urlAcademicStatus = '/dummy/json/hub_academic_status.json';
  var urlAdvisingAcademicStatus = '/api/advising/academic_status/';

  var parseAcademicRoles = function(response) {
    var roles = _.get(response, 'data.feed.student.roles');
    var isError = _.get(response, 'data.errored');
    return {
      roles: roles || {},
      isError: isError
    };
  };

  var parseHolds = function(response) {
    var holds = _.get(response, 'data.feed.student.holds');
    var isError = _.get(response, 'data.errored');
    return {
      holds: holds || [],
      isError: isError
    };
  };

  var fetch = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingAcademicStatus + $routeParams.uid : urlAcademicStatus;
    return apiService.http.request(options, url);
  };

  var getAcademicRoles = function(options) {
    return fetch(options).then(parseAcademicRoles);
  };

  var getHolds = function(options) {
    return fetch(options).then(parseHolds);
  };

  return {
    getAcademicRoles: getAcademicRoles,
    getHolds: getHolds
  };
});
