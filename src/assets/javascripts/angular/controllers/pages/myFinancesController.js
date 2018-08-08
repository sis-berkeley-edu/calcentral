'use strict';



/**
 * My Finances controller
 */
angular.module('calcentral.controllers').controller('MyFinancesController', function(apiService, linkService, $scope) {
  linkService.addCurrentRouteSettings($scope);
  apiService.util.setTitle($scope.currentPage.name);

  $scope.redirectToHome = function() {
    apiService.util.redirectToHome();
    return false;
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (!isAuthenticated || !apiService.user.profile.hasFinancialsTab) {
      apiService.user.redirectToHome();
    }
  });
});
