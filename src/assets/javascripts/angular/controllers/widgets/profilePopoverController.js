'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('ProfilePopoverController', function(profileFactory, linkService, $scope) {
  $scope.profilePopover = {
    isLoading: true
  };

  var getEditProfileLink = function() {
    linkService.addCurrentRouteSettings($scope);
    profileFactory.getProfileEditLink()
    .then(function(response) {
      $scope.profilePopover.link = _.get(response, 'data.feed.editProfile');
    })
    .finally(function() {
      $scope.profilePopover.isLoading = false;
    });
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      getEditProfileLink();
    }
  });
});
