'use strict';


var _ = require('lodash');

angular.module('calcentral.controllers').controller('TransferCreditController', function(transferCreditFactory, $scope) {

  $scope.transferCredits = {
    hasUnits: false,
    isLoading: true,
    law: {
      show: true
    },
    graduate: {
      show: false
    },
    undergraduate: {
      show: false,
      testUnits: {
        show: false
      }
    }
  };

  var loadTransferCredit = function() {
    transferCreditFactory.getTransferCredit()
      .then(function(response) {
        var transferCredits = _.get(response, 'data');
        $scope.transferCredits.hasUnits = _.get(transferCredits, 'hasUnits');
        angular.extend($scope.transferCredits.law, transferCredits.law);
        angular.extend($scope.transferCredits.graduate, transferCredits.graduate);
        angular.extend($scope.transferCredits.undergraduate, transferCredits.undergraduate);
      }).finally(function() {
        $scope.transferCredits.isLoading = false;
      });
  };

  loadTransferCredit();
});
