'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Dashboard controller
 */
angular.module('calcentral.controllers').controller('DashboardController', function($scope, apiService, academicStatusFactory, userService) {
  $scope.academicStatus = {
    roles: {}
  };

  var parseAcademicStatusRoles = function(data) {
    _.extend($scope.academicStatus.roles, _.get(data, 'data.feed.student.roles'));
  };

  var init = function() {
    if (apiService.user.profile.hasDashboardTab) {
      apiService.util.setTitle('Dashboard');
      academicStatusFactory.getAcademicStatus().then(parseAcademicStatusRoles);
    } else {
      userService.redirectToHome();
    }
  };

  // We have to watch the user profile for changes because of async loading in
  // case of Back button navigation from a different (non-CalCentral) location.
  $scope.$watch('api.user.profile.hasDashboardTab', init);
});
