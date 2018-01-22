'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Finaid Housing controller
 */
angular.module('calcentral.controllers').controller('FinaidHousingController', function($scope, finaidFactory, finaidService, linkService) {
  linkService.addCurrentRouteSettings($scope);

  var processHousingData = function(response) {
    $scope.housing = _.get(response, 'data.feed.housing');
    $scope.housing.errored = _.get(response, 'data.errored');
  };

  var loadHousing = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(
      processHousingData,
      function errorCallback() {
        $scope.housing.errored = true;
      }
    ).finally(function() {
      $scope.housing.isLoading = false;
    });
  };

  $scope.housingValuesArePresent = function() {
    var values = _.get($scope, 'housing.values');
    return (_.isArray(values) && values.length > 0);
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadHousing);
});
