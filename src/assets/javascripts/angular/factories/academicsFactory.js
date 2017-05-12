'use strict';

var angular = require('angular');
var _ = require('lodash');

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

  var getAcademicRoles = function() {
    return getAcademics().then(function(response) {
      return _.get(response, 'data.collegeAndLevel.roles');
    });
  };

  return {
    getAcademics: getAcademics,
    getAcademicRoles: getAcademicRoles,
    getResidency: getResidency
  };
});
