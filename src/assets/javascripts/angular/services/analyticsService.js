'use strict';

import {
  googleAnalytics
} from 'functions/googleAnalytics'

angular.module('calcentral.services').service('analyticsService', function(calcentralConfig, $rootScope, $location) {
  const ga = new googleAnalytics(calcentralConfig.applicationLayer);

  var sendEvent = function(category, action, label) {
    ga.sendEvent(category, action, label);
  };

  var trackExternalLink = function(section, website, url) {
    ga.trackExternalLink(section, website, url);
  };

  /**
   * Set the user id for the analytics service
   * @param {String} uid The uid of the current user
   * @return {undefined}
   */
  var setUserId = function(uid) {
    if (uid) {
      window.ga('set', '&uid', uid);
    }
  };

  /* eslint-disable */
  var injectAnalyticsCode = function() {
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

    window.ga('create', calcentralConfig.googleAnalyticsId , 'auto');
  };
  /* eslint-enable */

  var load = function() {
    if (ga.isProduction()) {
      injectAnalyticsCode(calcentralConfig.googleAnalyticsId);
      setUserId(calcentralConfig.uid);
    }
  };

  /*
   * This will track the the page that you're viewing
   * e.g. /, /dashboard
   */
  var trackPageview = function() {
    if (ga.isProduction()) {
      window.ga('send', 'pageview', $location.path());
    }
  };
  // Whenever we're changing the content loaded, we need to track which page we're viewing.
  $rootScope.$on('$viewContentLoaded', trackPageview);

  // Expose methods
  return {
    load: load,
    sendEvent: sendEvent,
    trackExternalLink: trackExternalLink
  };
});
