'use strict';

angular.module('calcentral.controllers').controller('AcademicSummaryController', function(academicsFactory, academicsService, apiService, linkService, profileFactory, transferCreditFactory, $route, $scope) {
  apiService.util.setTitle('Academic Summary');
  linkService.addCurrentRouteSettings($scope);
});
