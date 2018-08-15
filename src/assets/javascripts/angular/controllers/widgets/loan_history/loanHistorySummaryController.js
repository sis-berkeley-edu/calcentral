'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('LoanHistorySummaryController', function($scope, loanHistoryFactory) {
  $scope.loanHistory = {
    isLoading: true
  };

  var parseLoanHistorySummary = function(data) {
    var loanData = _.get(data, 'data');
    angular.merge($scope.loanHistory, loanData);
  };

  var init = function() {
    loanHistoryFactory.getSummary()
    .then(parseLoanHistorySummary)
    .finally(function() {
      $scope.loanHistory.isLoading = false;
    });
  };

  init();

});
