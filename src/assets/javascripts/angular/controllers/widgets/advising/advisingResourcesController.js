'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Advising Resources Controller
 * Show Campus Solutions links and favorite reports
 */
angular.module('calcentral.controllers').controller('AdvisingResourcesController', function(advisingFactory, apiService, linkService, $scope) {
  $scope.advisingResources = {
    isLoading: true
  };

  /**
   * Adds page name and url to link resource sets
   */
  var addPagePropertiesToLinks = function(resources) {
    if (_.get(resources, 'ucAdvisingResources.ucAdvisingFavoriteReports.length')) {
      linkService.addCurrentPagePropertiesToResources(resources.ucAdvisingResources.ucAdvisingFavoriteReports, $scope.currentPage.name, $scope.currentPage.url);
    }

    if (_.get(resources, '.links')) {
      linkService.addCurrentPagePropertiesToResources(resources.links, $scope.currentPage.name, $scope.currentPage.url);
    }

    if (_.get(resources, 'csLinks')) {
      linkService.addCurrentPagePropertiesToResources(resources.csLinks, $scope.currentPage.name, $scope.currentPage.url);
    }
  };

  /**
   * Parse the advising resources
   */
  var parseResources = function(data) {
    var resources = _.get(data, 'data.feed');

    addPagePropertiesToLinks(resources);
    angular.extend($scope, resources);
    $scope.advisingResources.isLoading = false;
  };

  /**
   * Load the advising resources
   */
  var loadResources = function() {
    advisingFactory.getResources().then(parseResources);
  };

  loadResources();
});
