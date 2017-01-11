'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').factory('linkService', function($location, $route) {
  /**
   * Add the back to text for external link objects
   */
  var addBackToTextToLink = function(link, backToText) {
    link.backToText = backToText;
    return link;
  };

  /**
   * Adds the back to text to each object in a resource collection
   */
  var addBackToTextToResources = function(resources, backToText) {
    var addBackToTextLinkWrapper = function(resource) {
      return addBackToTextToLink(resource, backToText);
    };
    return _.mapValues(resources, addBackToTextLinkWrapper);
  };

  /**
   * Extends the scope with the current page name and URL
   * Usage:
   *   $scope.currentPage.name // page name
   *   $scope.currentPage.url  // current page URL
   * @param {Object} $scope Controller scope object
   */
  var addCurrentRouteSettings = function($scope) {
    $scope.currentPage = {
      name: $route.current.pageName,
      url: $location.absUrl()
    };
  };

  return {
    addBackToTextToLink: addBackToTextToLink,
    addBackToTextToResources: addBackToTextToResources,
    addCurrentRouteSettings: addCurrentRouteSettings
  };
});
