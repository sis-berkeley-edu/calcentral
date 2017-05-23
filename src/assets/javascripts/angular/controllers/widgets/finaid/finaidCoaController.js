'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Finaid COA (Cost of Attendance) controller
 */
angular.module('calcentral.controllers').controller('FinaidCoaController', function($scope, finaidFactory, finaidService) {
  var knownViewKeys = ['fullyear', 'semester'];
  $scope.coa = {
    isLoading: true,
    validViewKeys: []
  };

  /**
   * Toggle between the semester & year view
   */
  $scope.toggleView = function() {
    if ($scope.coa.currentView === knownViewKeys[0]) {
      $scope.coa.currentView = knownViewKeys[1];
    } else {
      $scope.coa.currentView = knownViewKeys[0];
    }
  };

  /**
   * Modifies view categories to include title header and total
   * @param  {Object} scopeView   Reference to view object within $scope
   */
  var adaptCategoryTitles = function(scopeView) {
    var categories = scopeView.data;
    _.forEach(categories, function(category) {
      var categoryTitle = _.get(category, 'title');
      if (categoryTitle) {
        category.titleHeader = categoryTitle.replace(' Items', '');
        category.titleTotal = categoryTitle.replace(' Items', ' Total');
      }
    });
  };

  /**
   * Determines if view object is valid
   * @param  {Object}  rawView Raw view object as provided by API
   */
  var isInvalidView = function(rawView) {
    var viewData = _.get(rawView, 'data');
    if (!viewData || !_.isArray(viewData) || viewData.length < 1) {
      return true;
    }

    /* check for invalid categories */
    var hasInvalidCategory = _.find(viewData, function(category) {
      var items = _.get(category, 'items');
      if (!items || !_.isArray(items) || items.length < 1) {
        return true;
      }
    });
    return !!hasInvalidCategory;
  };

  var processViews = function(coaData) {
    _.forEach(knownViewKeys, function(viewKey) {
      var rawView = _.get(coaData, viewKey);
      if (isInvalidView(rawView)) {
        return;
      }
      $scope.coa.validViewKeys.push(viewKey);
      $scope.coa[viewKey] = rawView;
      adaptCategoryTitles($scope.coa[viewKey]);
    });
    $scope.coa.currentView = $scope.coa.validViewKeys[0];
  };

  var processCoaData = function(response) {
    var coaData = _.get(response, 'data.feed.coa');
    $scope.coa.errored = _.get(response, 'data.errored');
    $scope.coa.message = coaData.message;
    $scope.coa.title = coaData.titleHeader;
    processViews(coaData);
  };

  var loadCoa = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(
      processCoaData,
      function errorCallback() {
        $scope.coa.errored = true;
      }
    ).finally(function() {
      $scope.coa.isLoading = false;
    });
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadCoa);
});
