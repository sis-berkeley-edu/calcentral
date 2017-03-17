'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Finaid COA (Cost of Attendance) controller
 */
angular.module('calcentral.controllers').controller('FinaidCoaController', function($scope, finaidFactory, finaidService) {
  var views = ['fullyear', 'semester'];
  $scope.coa = {
    isLoading: true,
    currentView: views[0]
  };

  /**
   * Toggle between the semester & year view
   */
  $scope.toggleView = function() {
    if ($scope.coa.currentView === views[0]) {
      $scope.coa.currentView = views[1];
    } else {
      $scope.coa.currentView = views[0];
    }
  };

  var adaptCategoryTitles = function(coa) {
    _.forEach(views, function(view) {
      if (!coa[view]) {
        return;
      }
      var categories = coa[view].data;
      _.forEach(categories, function(category) {
        var categoryTitle = category.title;
        category.titleHeader = categoryTitle.replace(' Items', '');
        category.titleTotal = categoryTitle.replace(' Items', ' Total');
      });
    });
  };

  var loadCoa = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(
      function successCallback(response) {
        angular.extend($scope.coa, _.get(response, 'data.feed.coa'));
        adaptCategoryTitles($scope.coa);
        $scope.coa.errored = _.get(response, 'data.errored');
        $scope.coa.isLoading = false;
      }
    );
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadCoa);
});
