'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * My Finances controller
 */
angular.module('calcentral.controllers').controller('MyFinancesController', function($scope, apiService, academicStatusFactory) {
  apiService.util.setTitle('My Finances');

  $scope.academicStatus = {
    roles: {}
  };

  var parseAcademicStatusRoles = function(data) {
    _.extend($scope.academicStatus.roles, _.get(data, 'data.feed.student.roles'));
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated && apiService.user.profile.hasFinancialsTab) {
      academicStatusFactory.getAcademicStatus($scope).then(parseAcademicStatusRoles);
    }
  });
});
