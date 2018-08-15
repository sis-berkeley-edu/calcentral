'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('LoanHistoryCumulativeController', function($anchorScroll, $location, $scope, apiService, loanHistoryFactory, loanHistoryService) {
  apiService.util.setTitle('My Finances');

  $scope.loanHistory = {
    isLoading: true
  };

  $scope.showLoanList = function(loanCategory) {
    var downcased = loanCategory.toLowerCase();
    return !_.includes(downcased, 'perkins') && !_.includes(downcased, 'private');
  };

  $scope.scrollToDefinition = function(termCode, clickEvent) {
    loanHistoryService.scrollToDefinition(termCode, clickEvent, $location, $anchorScroll);
  };

  $scope.isFederalDirectLoan = function(loanCategory) {
    var downcased = loanCategory.toLowerCase();
    return _.includes(downcased, 'direct');
  };

  $scope.showAmountOwedVerbiage = function(loanCategory) {
    var downcased = loanCategory.toLowerCase();
    return !_.includes(downcased, 'state') && !_.includes(downcased, 'private');
  };

  var checkLoanActiveStatus = function() {
    loanHistoryService.checkLoanActiveStatus()
    .then(function(isActive) {
      if (isActive) {
        init();
      } else {
        apiService.util.redirect('finances/loan_resources');
      }
    });
  };

  var init = function() {
    loanHistoryFactory.getCumulative()
    .then(parseLoanHistoryCumulative)
    .finally(function() {
      $scope.loanHistory.isLoading = false;
    });
  };

  var parseLoanHistoryCumulative = function(data) {
    var loanData = _.get(data, 'data');
    angular.merge($scope.loanHistory, loanData);
  };

  checkLoanActiveStatus();
});
