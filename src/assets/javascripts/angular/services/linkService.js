'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').factory('linkService', function($location, $route) {
  /**
   * Add the page name and url to a link object
   * Designed for use on objects used with ccCampusSolutionsLinkDirective to include current page name and URL
   */
  var addCurrentPagePropertiesToLink = function(link, pageName, pageUrl) {
    link.ccPageName = pageName;
    link.ccPageUrl = pageUrl;
    return link;
  };

  /**
   * Adds the current page name and URL to each object in a resource collection
   * Designed for use on objects used with ccCampusSolutionsLinkDirective
   */
  var addCurrentPagePropertiesToResources = function(resources, pageName, pageUrl) {
    var addCurrentPagePropertiesToResourcesWrapper = function(resource) {
      resource = addCurrentPagePropertiesToLink(resource, pageName, pageUrl);
      return resource;
    };
    return _.mapValues(resources, addCurrentPagePropertiesToResourcesWrapper);
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

  /**
   * Sometimes Campus Solutions gives us links that end with a question mark, we should clean those up
   * /EMPLOYEE/HRMS/c/MAINTAIN_SERVICE_IND_STDNT.ACTIVE_SRVC_INDICA.GBL?
   */
  var fixLastQuestionMark = function(link) {
    if (link.indexOf('?', link.length - 1) !== -1) {
      link = link.slice(0, -1);
    }
    return link;
  };

  /**
   * Configures an anchor element to an outbound link, opening in a new window
   * @param  {Element} linkElement HTML anchor element
   */
  var makeOutboundlink = function(linkElement) {
    var screenReadMessage = document.createElement('span');
    screenReadMessage.className = 'cc-outbound-link cc-visuallyhidden cc-print-hide';
    screenReadMessage.innerHTML = ' - opens in new window';
    linkElement.append(screenReadMessage);
    linkElement.addClass('cc-outbound-link');
    linkElement.attr('target', '_blank');
  };

  /**
   * Update a querystring parameter
   * We'll add it when there is none and update it when there is
   * @param {String} uri The URI you want to update
   * @param {String} key The key of the param you want to update
   * @param {String} value The value of the param you want to update
   * @return {String} The updated URI
   */
  var updateQueryStringParameter = function(uri, key, value) {
    var re = new RegExp('([?&])' + key + '=.*?(&|$)', 'i');
    var separator = uri.indexOf('?') !== -1 ? '&' : '?';
    if (uri.match(re)) {
      return uri.replace(re, '$1' + key + '=' + value + '$2');
    } else {
      return uri + separator + key + '=' + value;
    }
  };

  /* Temporary hack to get CalCentral through testing of 9.2 - See SISRP-33544 */
  var addQueryStringParameterEncodedAmpersand = function(uri, key, value) {
    var separator = uri.indexOf('?') !== -1 ? '%26' : '?';
    return uri + separator + key + '=' + value;
  };

  return {
    addCurrentPagePropertiesToLink: addCurrentPagePropertiesToLink,
    addCurrentPagePropertiesToResources: addCurrentPagePropertiesToResources,
    addCurrentRouteSettings: addCurrentRouteSettings,
    addQueryStringParameterEncodedAmpersand: addQueryStringParameterEncodedAmpersand,
    fixLastQuestionMark: fixLastQuestionMark,
    makeOutboundlink: makeOutboundlink,
    updateQueryStringParameter: updateQueryStringParameter
  };
});
