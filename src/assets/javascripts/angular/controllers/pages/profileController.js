'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Profile controller
 */
angular.module('calcentral.controllers').controller('ProfileController', function(apiService, linkService, profileMenuService, $routeParams, $scope) {
  linkService.addCurrentRouteSettings($scope);

  /**
   * Find the category object when we get a categoryId back
   */
  var findCategory = function(categoryId, navigation) {
    return _.find(_.flatten(_.map(navigation, 'categories')), {
      id: categoryId
    });
  };

  /**
   * Get the category depending on the routeParam
   */
  var getCurrentCategory = function(navigation) {
    if (!navigation || !navigation.length) {
      return false;
    }
    if ($routeParams.category) {
      return findCategory($routeParams.category, navigation);
    } else {
      return navigation[0].categories[0];
    }
  };

  /**
   * Set the page title
   */
  var setPageTitle = function() {
    var title = $scope.currentCategory.name + ' - ' + $scope.header;
    apiService.util.setTitle(title);
  };

  /**
   * Get the navigation for the profile page
   * This will depend on feature flags and the user's roles
   */
  var getNavigation = function() {
    return profileMenuService.getNavigation();
  };

  /**
   * Set the correct navigation information
   */
  var setNavigation = function(navigation) {
    var currentCategory = getCurrentCategory(navigation);

    // If no category was found, redirect to the 404 page
    if (!currentCategory) {
      apiService.util.redirect('404');
      return false;
    }

    $scope.header = navigation[0].label;
    $scope.currentCategory = currentCategory;
    $scope.navigation = navigation;

    setPageTitle();
  };

  var init = function() {
    return getNavigation().then(setNavigation);
  };

  init();
});
