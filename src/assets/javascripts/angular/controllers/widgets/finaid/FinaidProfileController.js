'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Financial Aid & Scholarships Profile controller
 */
angular.module('calcentral.controllers').controller('FinaidProfileController', function($scope, finaidFactory, finaidService) {
  $scope.finaidProfileInfo = {
    isLoading: true
  };
  $scope.finaidProfile = {};

  var loadProfile = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(
      function successCallback(response) {
        angular.extend($scope.finaidProfile, _.get(response, 'data.feed.status'));
        $scope.finaidProfileInfo.errored = _.get(response, 'data.errored');
        $scope.finaidProfileInfo.isLoading = false;
        if ($scope.finaidProfile.categories[0]) {
          _.set($scope.finaidProfile.categories[0], 'show', true);
        }
      }
    );
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadProfile);
});
