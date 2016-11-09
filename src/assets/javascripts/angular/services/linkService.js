'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').factory('linkService', function() {
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

  return {
    addBackToTextToLink: addBackToTextToLink,
    addBackToTextToResources: addBackToTextToResources
  };
});
