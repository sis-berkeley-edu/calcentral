'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('LoanHistoryAidYearController', function($location, $scope, $anchorScroll, apiService, loanHistoryFactory, loanHistoryService) {
  apiService.util.setTitle('My Finances');

  $scope.loanHistory = {
    isLoading: true
  };

  $scope.scrollToDefinition = function(termCode, clickEvent) {
    loanHistoryService.scrollToDefinition(termCode, clickEvent, $location, $anchorScroll);
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
    loanHistoryFactory.getAidYears()
    .then(parseLoanHistoryAidYears)
    .finally(function() {
      $scope.loanHistory.isLoading = false;
    });
  };

  var parseLoanHistoryAidYears = function(data) {
    var loanData = _.get(data, 'data');
    angular.merge($scope.loanHistory, loanData);
  };

  checkLoanActiveStatus();
});
