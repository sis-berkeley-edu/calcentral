'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Advising Resources Controller
 * Show Campus Solutions links and favorite reports
 */
angular.module('calcentral.controllers').controller('AdvisingResourcesController', function(advisingFactory, apiService, $scope) {
  $scope.advisingResources = {
    isLoading: true
  };

  var backToText = 'My Dashboard';

  /**
   * Add the back to text (used for Campus Solutions) to the link
   */
  var addBackToTextLink = function(link) {
    link.backToText = backToText;
    return link;
  };

  /**
   * Add the back to text
   */
  var addBackToText = function(resources) {
    if (_.get(resources, 'ucAdvisingResources.ucAdvisingFavoriteReports.length')) {
      _.mapValues(resources.ucAdvisingResources.ucAdvisingFavoriteReports, addBackToTextLink);
    }

    if (_.get(resources, '.links')) {
      _.mapValues(resources.links, addBackToTextLink);
    }

    if (_.get(resources, 'csLinks')) {
      _.mapValues(resources.csLinks, addBackToTextLink);
    }

    return resources;
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
