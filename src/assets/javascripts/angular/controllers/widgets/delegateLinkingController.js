'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Controller links student account with the requested delegate account
 */
angular.module('calcentral.controllers').controller('DelegateLinkingController', function(apiService, delegateFactory, $scope) {
  angular.extend($scope, {
    delegate: {
      currentObject: {},
      isLoading: true,
      termsAndConditionsVisible: false,
      isSaving: false
    }
  });

  $scope.save = function(item) {
    $scope.delegate.isSaving = true;
    apiService.delegate.save($scope, delegateFactory.linkAccounts, {
      securityKey: item.securityKey,
      proxyEmailAddress: item.proxyEmailAddress,
      agreeToTerms: item.agreeToTerms
    }).then(saveCompleted);
  };

  var saveCompleted = function(data) {
    $scope.delegate.isSaving = false;
    apiService.delegate.actionCompleted(data).then(showLinkedStudents, function(errorMessage) {
      $scope.delegate.errorMessage = errorMessage;
    });
  };

  var showLinkedStudents = function() {
    apiService.util.redirectToToolbox();
  };

  $scope.getTermsAndConditions = function() {
    delegateFactory.getTermsAndConditions().then(
      function successCallback(response) {
        angular.extend($scope, _.get(response, 'data.feed'));
        $scope.delegate.termsAndConditionsVisible = true;
      },
      function errorCallback() {
        $scope.delegate.errorMessage = 'The system failed to get Terms and Conditions.';
      }
    );
  };

  var loadInformation = function() {
    $scope.delegate.isLoading = false;
  };

  loadInformation();
});
