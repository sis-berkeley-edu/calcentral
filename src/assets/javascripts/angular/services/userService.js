'use strict';

var _ = require('lodash');
var angular = require('angular');

angular.module('calcentral.services').service('userService', function($http, $location, $route, analyticsService, httpService, utilService, calcentralConfig) {
  var profile = {};
  var events = {
    isLoaded: false,
    isAuthenticated: false,
    isAuthenticatedAndHasGoogle: false,
    profile: false
  };
  var statusUrl = '/api/my/status';
  var providedServices = calcentralConfig.providedServices;

  // Private methods that are only exposed for testing but shouldn't be used within the views

  /**
   * Opt in for a student to see the course schedule on the calendar
   */
  var calendarOptIn = function() {
    $http.post('/api/my/calendar/opt_in').success(function() {
      analyticsService.sendEvent('Calendar Courses', 'Enable');
      fetch();
    });
  };

  /**
   * Opt out for a student to see the course schedule on the calendar
   */
  var calendarOptOut = function() {
    $http.post('/api/my/calendar/opt_out').success(function() {
      analyticsService.sendEvent('Calendar Courses', 'Remove');
      fetch();
    });
  };

  /**
   * Redirect user to the dashboard when you're on the splash page
   */
  var redirectToHome = function() {
    if ($location.path() === '/') {
      analyticsService.sendEvent('Authentication', 'Redirect to dashboard');
      if (providedServices.indexOf('calcentral') !== -1) {
        if (profile.hasDashboardTab) {
          utilService.redirect('dashboard');
        } else if (profile.hasAcademicsTab) {
          utilService.redirect('academics');
        } else if (profile.hasFinancialsTab) {
          utilService.redirect('finances');
        } else {
          utilService.redirect('campus');
        }
      } else {
        utilService.redirect('toolbox');
      }
    }
  };

  /**
   * Set the user firstLoginAt attribute
   */
  var setFirstLogin = function() {
    profile.firstLoginAt = (new Date()).getTime();
    redirectToHome();
  };

  /**
   * Handle the access to the page that the user is watching
   * This will depend on
   *   - whether they are logged in or not
   *   - whether the page is public
   */
  var handleAccessToPage = function() {
    // Redirect to the login page when the page is private and you aren't authenticated
    if (!$route.current.isPublic && !events.isAuthenticated) {
      analyticsService.sendEvent('Authentication', 'Sign in - redirect to login');
      signIn();
    // Record that the user visited calcentral
    } else if (events.isAuthenticated && !profile.firstLoginAt && !profile.actingAsUid && !profile.delegateActingAsUid && !profile.advisorActingAsUid) {
      analyticsService.sendEvent('Authentication', 'First login');
      $http.post('/api/my/record_first_login').success(setFirstLogin);
    // Redirect to the dashboard when you're accessing the root page and are authenticated
    } else if (events.isAuthenticated) {
      redirectToHome();
    }
  };

  /**
   * Set extra properties for a user
   */
  var setExtraProperties = function(profile) {
    if (profile.roles) {
      // Set this boolean to true when they only have the applicant role
      profile.isApplicantOnly = (_.size(profile.roles) === 1 && profile.roles.applicant);
    }

    // Set whether the current user can POST information when acting as someone
    profile.actAsOptions = {
      canPost: !(_.get(profile, 'features.preventActingAsUsersFromPosting') && !profile.isDirectlyAuthenticated),
      canSeeCSLinks: (profile.canSeeCSLinks && !$route.current.isAdvisingStudentLookup)
    };

    return profile;
  };

  /**
   * Set the current user information
   */
  var handleUserLoaded = function(data) {
    angular.extend(profile, data);

    // Set extra properties on the profile
    profile = setExtraProperties(profile);

    events.isLoaded = true;
    // Check whether the current user is authenticated or not
    events.isAuthenticated = profile && profile.isLoggedIn;
    // Check whether the current user is authenticated and has a google access token
    events.isAuthenticatedAndHasGoogle = profile.isLoggedIn && profile.hasGoogleAccessToken;
    // Expose the profile into events
    events.profile = profile;

    handleAccessToPage();
  };

  /**
   * Get the actual user information
   * @param {Object} options Options that need to be passed through
   */
  var fetch = function(options) {
    httpService.clearCache(options, statusUrl);

    return $http.get(statusUrl, {
      cache: true
    }).then(function(xhr) {
      return handleUserLoaded(xhr.data);
    });
  };

  var enableOAuth = function(authorizationService) {
    analyticsService.sendEvent('OAuth', 'Enable', 'service: ' + authorizationService);
    window.location = '/api/' + authorizationService.toLowerCase() + '/request_authorization';
  };

  var handleRouteChange = function() {
    if (!profile.features) {
      fetch();
    } else {
      handleAccessToPage();
    }
  };

  /**
   * Sign the current user in.
   */
  var signIn = function() {
    analyticsService.sendEvent('Authentication', 'Redirect to login');
    window.location = '/auth/cas';
  };

  /**
   * Remove OAuth permissions for a service for the currently logged in user
   * @param {String} authorizationService The authorization service (e.g. 'google')
   */
  var removeOAuth = function(authorizationService) {
    // Send the request to remove the authorization for the specific OAuth service
    // Only when the request was successful, we update the UI
    $http.post('/api/' + authorizationService.toLowerCase() + '/remove_authorization').success(function() {
      analyticsService.sendEvent('OAuth', 'Remove', 'service: ' + authorizationService);
      profile['has' + authorizationService + 'AccessToken'] = false;
    });
  };

  /**
   * Sign the current user out.
   */
  var signOut = function() {
    $http.post('/logout').success(function(data) {
      if (data && data.redirectUrl) {
        analyticsService.sendEvent('Authentication', 'Redirect to logout');
        window.location = data.redirectUrl;
      }
    }).error(function(data, responseCode) {
      if (responseCode && responseCode === 401) {
        // User is already logged out
        window.location = '/';
      }
    });
  };

  // Expose methods
  return {
    calendarOptIn: calendarOptIn,
    calendarOptOut: calendarOptOut,
    enableOAuth: enableOAuth,
    events: events,
    fetch: fetch,
    handleAccessToPage: handleAccessToPage,
    handleRouteChange: handleRouteChange,
    handleUserLoaded: handleUserLoaded,
    profile: profile,
    redirectToHome: redirectToHome,
    removeOAuth: removeOAuth,
    setFirstLogin: setFirstLogin,
    signIn: signIn,
    signOut: signOut
  };
});
