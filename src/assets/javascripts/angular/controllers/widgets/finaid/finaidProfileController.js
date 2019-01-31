'use strict';

angular
.module('calcentral.controllers')
.controller('FinaidProfileController', function(finaidProfileFactory, title4Factory, termsAndConditionsFactory, $scope, $routeParams) {
  $scope.finaidProfile = {
    isLoading: true
  };

  const getFinaidProfile = function(options) {
    return finaidProfileFactory.getFinaidProfile(options)
    .then(
      function(response) {
        $scope.finaidProfile = response.data.finaidProfile;
      }
    )
    .finally(function() {
      $scope.finaidProfile.isLoading = false;
    });
  };

  const getTitle4 = function(options) {
    return title4Factory.getTitle4(options).then(
      function(response) {
        $scope.title4Description = response.data.title4.responseDescr;
      }
    );
  };

  const getTermsAndConditions = function(options) {
    return termsAndConditionsFactory.getTermsAndConditions(options).then(
      function(response) {
        $scope.termsAndConditionsDescription = response.data.termsAndConditions.responseDescr;
      }
    );
  };

  getFinaidProfile({ finaidYear: $routeParams.finaidYearId });

  getTitle4();

  getTermsAndConditions( {finaidYear: $routeParams.finaidYearId} );
});
