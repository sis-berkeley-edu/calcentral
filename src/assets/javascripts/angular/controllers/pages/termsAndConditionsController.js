'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('TermsAndConditionsController', function(termsAndConditionsFactory, $scope, $routeParams, $rootScope) {
  $scope.termsAndConditions = {
    isLoading: true
  };

  var sendEvent = function() {
    $rootScope.$broadcast('calcentral.custom.api.finaid.approvals');
  };

  $scope.sendResponseTC = function(finaidYearId, response) {
    $scope.termsAndConditions.isLoading = true;
    termsAndConditionsFactory.postTCResponse(finaidYearId, response).then(sendEvent);
  };

  var getTermsAndConditions = function(options) {
    return termsAndConditionsFactory.getTermsAndConditions(options).then(
      function successCallback(response) {
        var termsAndConditions = _.get(response, 'data.termsAndConditions');
        $scope.termsAndConditions = termsAndConditions;
        $scope.termsAndConditions.isLoading = false;
      }
    );
  };

  getTermsAndConditions({ finaidYear: $routeParams.finaidYearId });

  $scope.$on('calcentral.custom.api.finaid.approvals', function() {
    getTermsAndConditions({
      finaidYear: $routeParams.finaidYearId,
      refreshCache: true
    });
  });
});
