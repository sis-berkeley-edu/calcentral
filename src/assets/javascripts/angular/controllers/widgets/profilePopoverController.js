'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('ProfilePopoverController', function(csLinkFactory, linkService, $scope) {
  $scope.profilePopover = {
    isLoading: true
  };

  var loadLink = function() {
    linkService.addCurrentRouteSettings($scope);
    csLinkFactory.getLink({
      urlId: 'UC_CX_PROFILE'
    }).then(function(response) {
      $scope.profilePopover.link = _.get(response, 'data.link');
      $scope.profilePopover.isLoading = false;
    });
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      loadLink();
    }
  });
});
