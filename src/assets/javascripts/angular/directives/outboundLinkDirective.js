'use strict';

var angular = require('angular');

/**
 * Parse a request and location URL and determine whether this is a same-domain request.
 * This function has been copied over from AngularJS since they don't expose this function
 * @param {string} requestUrl The url of the request.
 * @param {string} locationUrl The current browser location url.
 * @returns {boolean} Whether the request is for the same domain.
 */
var isSameDomain = function(requestUrl, locationUrl) {
  var DEFAULT_PORTS = {
    'http': 80,
    'https': 443,
    'ftp': 21
  };
  var IS_SAME_DOMAIN_URL_MATCH = /^(([^:]+):)?\/\/(\w+:{0,1}\w*@)?([\w\.-]*)?(:([0-9]+))?(.*)$/;
  var URL_MATCH = /^([^:]+):\/\/(\w+:{0,1}\w*@)?([\w\.-]*)(:([0-9]+))?(\/[^\?#]*)?(\?([^#]*))?(#(.*))?$/;

  var match = IS_SAME_DOMAIN_URL_MATCH.exec(requestUrl);
  // If requestUrl is relative, the regex does not match.
  if (match === null) {
    return true;
  }

  var domain1 = {
    protocol: match[2],
    host: match[4],
    port: parseInt(match[6], 10) || DEFAULT_PORTS[match[2]] || null,
    // IE8 sets unmatched groups to '' instead of undefined.
    relativeProtocol: match[2] === undefined || match[2] === ''
  };

  match = URL_MATCH.exec(locationUrl);
  var domain2 = {
    protocol: match[1],
    host: match[3],
    port: parseInt(match[5], 10) || DEFAULT_PORTS[match[1]] || null
  };

  return (domain1.protocol === domain2.protocol || domain1.relativeProtocol) &&
         domain1.host === domain2.host &&
         (domain1.port === domain2.port || (domain1.relativeProtocol &&
             domain2.port === DEFAULT_PORTS[domain2.protocol]));
};

/**
 * This directive will make sure that external links are always opened in a new window
 * To make it more accessible, we also add an extra message to each element.
 */
angular.module('calcentral.directives').directive('a', function(linkService) {
  return {
    restrict: 'E',
    // We need to run this after ngHref has changed
    priority: 200,
    link: function(scope, element, attr) {
      /**
       * We update the anchor tag
       * @param {String} url The URL of the anchor tag.
       */
      var updateAnchorTag = function(url) {
        // We only want to change anchor tags that link to a different domain
        // Since this gets executed a couple of times, we add a class to the screenreader message & check for it
        if ((attr.ccOutboundEnabled === 'true' || !isSameDomain(url, location.href)) && !element[0].querySelector('.cc-outbound-link')) {
          linkService.makeOutboundlink(element);
        }
      };

      /**
       * Check whether the href attribute has changed
       */
      var observe = function(value) {
        // Check whether the element actually has an href,
        // whether we disabled the outbound directive,
        // and if the ccCampusSolutionsLinkDirective is present
        if (value && scope.$eval(attr.ccOutboundEnabled) !== false && !(attr.ccCampusSolutionsLinkDirective || attr.ccCampusSolutionsLinkDirectiveUrl)) {
          updateAnchorTag(value);
        }
      };

      attr.$observe('href', observe);
    }
  };
});
