'use strict';

import { fetchFinancialAidProfile } from 'Redux/actions/financialAid/financialAidProfileActions';

angular
.module('calcentral.controllers')
.controller('FinaidProfileController', function($scope, $ngRedux, $routeParams) {
  $scope.finaidProfile = {};

  $ngRedux.subscribe(() => {
    const {
      financialAid: {
        profile: {
          [$routeParams.finaidYearId]: finaidYearProfile = {}
        }
      }
    } = $ngRedux.getState();

    $scope.finaidProfile = finaidYearProfile;
    $scope.finaidProfile.isLoading = finaidYearProfile.isLoading;
  });

  $ngRedux.dispatch(fetchFinancialAidProfile($routeParams.finaidYearId || ''));
});
