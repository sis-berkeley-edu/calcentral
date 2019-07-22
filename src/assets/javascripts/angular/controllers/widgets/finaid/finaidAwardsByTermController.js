'use strict';

var _ = require('lodash');

/**
 * Financial Aid - Awards controller
 */
angular.module('calcentral.controllers').controller('FinaidAwardsTermController', function($routeParams, $scope, finaidAwardsByTermFactory) {
  $scope.finaidAwardsTerm = {
    isLoading: true,
    showDecimals: false,
    feed: {}
  };

  var formatCurrency = function(amount, showDecimals) {
    return showDecimals ? amount.toFixed(2) : amount;
  };

  const notInteger = (value) => !Number.isInteger(value);

  const awardIsNotInteger = (award) => {
    const { amounts = [] } = award;
    return amounts.find(notInteger);
  };

  var shouldShowDecimals = function(awards) {
    return awards.find(awardIsNotInteger);
  };

  var loadAwardsByTerm = function() {
    return finaidAwardsByTermFactory.getAwardsByTerm({
      finaidYearId: $routeParams.finaidYearId
    }).then(
      function successCallback(response) {
        angular.extend($scope.finaidAwardsTerm.feed, _.get(response, 'data.feed'));
        $scope.finaidAwardsTerm.errored = _.get(response, 'data.errored');
        $scope.finaidAwardsTerm.showDecimals = shouldShowDecimals(_.get(response, 'data.feed.awards.semester.data[0].items'));
      })
    .finally(function() {
      $scope.finaidAwardsTerm.formatCurrency = formatCurrency;
      $scope.finaidAwardsTerm.isLoading = false;
    });
  };

  loadAwardsByTerm();
  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadAwardsByTerm);
});
