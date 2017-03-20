'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * My Finances controller
 */
angular.module('calcentral.controllers').controller('MyFinancesController', function(academicStatusFactory, apiService, linkService, $scope) {
  linkService.addCurrentRouteSettings($scope);
  apiService.util.setTitle($scope.currentPage.name);

  $scope.academicStatus = {
    roles: {}
  };

  $scope.redirectToHome = function() {
    return apiService.util.redirectToHome();
  };

  var loadAcademicRoles = function() {
    return academicStatusFactory.getAcademicRoles()
      .then(function(data) {
        $scope.academicStatus.roles = _.get(data, 'roles');
      });
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated && apiService.user.profile.hasFinancialsTab) {
      loadAcademicRoles();
    } else {
      apiService.user.redirectToHome();
    }
  });
});
