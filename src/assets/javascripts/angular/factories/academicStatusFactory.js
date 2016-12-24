'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Academic Status Factory
 */
angular.module('calcentral.factories').factory('academicStatusFactory', function(apiService, $route, $routeParams) {
  // var urlAcademicStatus = '/dummy/json/hub_academic_status.json';
  var urlAcademicStatus = '/api/edos/academic_status';
  var urlAdvisingAcademicStatus = '/api/advising/academic_status/';

  var parseAcademicRoles = function(data) {
    var roles = _.get(data, 'data.feed.student.roles');
    var isError = _.get(data, 'data.errored');
    return {
      roles: roles || {},
      isError: isError
    };
  };

  var parseHolds = function(data) {
    var holds = _.get(data, 'data.feed.student.holds');
    var isError = _.get(data, 'data.errored');
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
    return fetch(options)
      .then(parseAcademicRoles);
  };

  var getHolds = function(options) {
    return fetch(options)
      .then(parseHolds);
  };

  return {
    getAcademicRoles: getAcademicRoles,
    getHolds: getHolds
  };
});
