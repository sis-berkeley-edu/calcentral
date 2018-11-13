'use strict';

var _ = require('lodash');

/**
 * Financial Aid Terms and Conditions controller
 */
angular.module('calcentral.controllers').controller('TermsAndConditionsController', function(termsAndConditionsFactory, $scope, $routeParams) {
  $scope.termsAndConditions = {
    isLoading: true
  };

  var getTermsAndConditions = function() {
    var options = {
      finaidYear: $routeParams.finaidYearId
    };
    return termsAndConditionsFactory.getTermsAndConditions(options).then(
      function successCallback(response) {
        var termsAndConditions = _.get(response, 'data.termsAndConditions');
        $scope.termsAndConditions = termsAndConditions;
        $scope.termsAndConditions.isLoading = false;
      }
    );
  };

  getTermsAndConditions();

  $scope.$on('calcentral.custom.api.finaid.approvals', function() {
    termsAndConditionsFactory.getTermsAndConditions();
  });
});
