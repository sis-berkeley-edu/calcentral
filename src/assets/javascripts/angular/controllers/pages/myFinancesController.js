'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * My Finances controller
 */
angular.module('calcentral.controllers').controller('MyFinancesController', function($scope, apiService) {
  apiService.util.setTitle('My Finances');

  $scope.academicStatus = {
    roles: {}
  };

  var parseAcademicStatusRoles = function() {
    _.extend($scope.academicStatus.roles, apiService.academics.roles);
  };

  var getAcademics = function() {
    return apiService.academics.fetch();
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated && apiService.user.profile.hasFinancialsTab) {
      getAcademics()
        .then(parseAcademicStatusRoles);
    }
  });
});
