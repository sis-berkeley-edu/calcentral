'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Housing controller
 */
angular.module('calcentral.controllers').controller('HousingController', function($scope, housingFactory, finaidService, linkService) {
  $scope.housing = {
    isLoading: true
  };
  linkService.addCurrentRouteSettings($scope);

  var parseHousing = function(response) {
    angular.extend($scope.housing, _.get(response, 'data.housing'));
    $scope.housing.errored = _.get(response, 'data.errored');
  };

  var loadHousing = function() {
    return housingFactory.getHousing({
      aidYear: finaidService.options.finaidYear.id
    }).then(
      parseHousing,
      function errorCallback() {
        $scope.housing.errored = true;
      }
    ).finally(function() {
      $scope.housing.isLoading = false;
    });
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadHousing);
});
