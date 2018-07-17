'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('LoanHistoryResourcesController', function($scope, apiService, loanHistoryFactory, loanHistoryService) {
  apiService.util.setTitle('My Finances');

  $scope.loanHistory = {
    isLoading: true
  };

  var checkLoanActiveStatus = function() {
    loanHistoryService.checkLoanActiveStatus()
    .then(function(isActive) {
      if (isActive) {
        apiService.util.redirect('finances/cumulative_loan_debt');
      } else {
        init();
      }
    });
  };

  var init = function() {
    loanHistoryFactory.getInactive()
    .then(parseLoanHistoryInactive)
    .finally(function() {
      $scope.loanHistory.isLoading = false;
    });
  };

  var parseLoanHistoryInactive = function(data) {
    var resources = _.get(data, 'data');
    angular.merge($scope.loanHistory, resources);
  };

  checkLoanActiveStatus();
});
