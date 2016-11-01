'use strict';

var angular = require('angular');

/**
 * Directive for Campus Solutions links
 * This will allow for the 'Back to CalCentral' branding in Campus Solutions
 * and have a way to refresh the cache for CS specific items
 *
 * Usage:
 *   data-cc-campus-solutions-link-directive="testUrl" // CS URL
 *   data-cc-campus-solutions-link-directive-enabled="{{item.isCsLink}}" // Default is true, if set to false, we don't execute this directive
 *   data-cc-campus-solutions-link-directive-text="backToText" // For the 'Back to ...'' text in CS
 *   data-cc-campus-solutions-link-directive-cache="'finaid'" // Will add an addition querystring to the back to link to expire the cache (e.g. 'finaid' or 'profile')
 */
angular.module('calcentral.directives').directive('ccCampusSolutionsLinkDirective', function($compile, $location, $parse) {
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

  /**
   * Get the Back To CalCentral link
   */
  var getCalCentralLink = function(cacheParam) {
    var link = $location.absUrl();
    if (cacheParam) {
      // We need to do the extra encoding, otherwise, the complete URL will be incorrect
      link = encodeURIComponent(updateQueryStringParameter(link, 'ucUpdateCache', cacheParam));
    }
    return link;
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

  return {
    // It needs to run after the attributes are interpolated
    priority: 99,
    restrict: 'A',
    link: function(scope, element, attrs) {
      scope.$watch(attrs.ccCampusSolutionsLinkDirective, function(value) {
        if (!value) {
          return;
        }
        var csBannerEnabled = scope.$eval(attrs.ccCampusSolutionsLinkDirectiveEnabled);
        if (/^http/.test(value) && csBannerEnabled === true) {
          value = fixLastQuestionMark(value);
          value = updateQueryStringParameter(value, 'ucFrom', 'CalCentral');
          var calCentrallink = getCalCentralLink(scope.$eval(attrs.ccCampusSolutionsLinkDirectiveCache));
          value = updateQueryStringParameter(value, 'ucFromLink', calCentrallink);
          var textAttribute = attrs.ccCampusSolutionsLinkDirectiveText;
          if (textAttribute) {
            var text = $parse(textAttribute)(scope);
            if (text) {
              value = updateQueryStringParameter(value, 'ucFromText', text);
            }
          }
        }

        attrs.$set('href', value);

        // Links from the CS Link API may contain `comments` attributes, which
        // are renamed on CalCentral to `title` in order to support hover text.
        if (scope.link && scope.link.title) {
          attrs.$set('title', scope.link.title);
        }
      });
    }
  };
});

