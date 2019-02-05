'use strict';

angular
.module('calcentral.controllers')
.controller('TermsAndConditionsController', function(termsAndConditionsFactory, $scope, $routeParams) {
  $scope.termsAndConditions = {
    isLoading: true
  };

  $scope.sendResponseTC = function(finaidYearId, response) {
    $scope.termsAndConditions.isLoading = true;
    termsAndConditionsFactory.postTCResponse(finaidYearId, response).then(function() {
      getTermsAndConditions({
        finaidYear: $routeParams.finaidYearId,
        refreshCache: true
      });
    });
  };

  var getTermsAndConditions = function(options) {
    return termsAndConditionsFactory.getTermsAndConditions(options).then(
      function successCallback({ data }) {
        $scope.termsAndConditions = data.termsAndConditions;
        $scope.termsAndConditions.isLoading = false;
      }
    );
  };

  getTermsAndConditions({ finaidYear: $routeParams.finaidYearId });
});
