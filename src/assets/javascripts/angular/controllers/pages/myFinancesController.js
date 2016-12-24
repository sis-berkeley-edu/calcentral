'use strict';

var angular = require('angular');

/**
 * My Finances controller
 */
angular.module('calcentral.controllers').controller('MyFinancesController', function($scope, apiService, academicStatusFactory) {
  apiService.util.setTitle('My Finances');

  $scope.academicStatus = {
    roles: {}
  };

  var loadAcademicRoles = function() {
    return academicStatusFactory.getAcademicRoles()
      .then(function(data) {
        $scope.academicStatus.roles = data.roles;
      });
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated && apiService.user.profile.hasFinancialsTab) {
      loadAcademicRoles();
    }
  });
});
