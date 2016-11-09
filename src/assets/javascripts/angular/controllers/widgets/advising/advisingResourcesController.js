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

  var backToText = 'My Dashboard';

  /**
   * Add the back to text
   */
  var addBackToText = function(resources) {
    if (_.get(resources, 'ucAdvisingResources.ucAdvisingFavoriteReports.length')) {
      linkService.addBackToTextToResources(resources.ucAdvisingResources.ucAdvisingFavoriteReports, backToText);
    }

    if (_.get(resources, '.links')) {
      linkService.addBackToTextToResources(resources.links, backToText);
    }

    if (_.get(resources, 'csLinks')) {
      linkService.addBackToTextToResources(resources.csLinks, backToText);
    }
  };

  /**
   * Parse the advising resources
   */
  var parseResources = function(data) {
    var resources = _.get(data, 'data.feed');

    addBackToText(resources);
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
