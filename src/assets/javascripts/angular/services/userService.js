import _ from 'lodash';
import {
  fetchStatusStart,
  fetchStatusSuccess,
  fetchStatusFailure
} from 'Redux/actions/statusActions';

angular.module('calcentral.services').service('userService', function($http, $location, $route, analyticsService, httpService, utilService, calcentralConfig, $ngRedux) {
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
        } else if (profile.hasCampusTab) {
          utilService.redirect('campus');
        } else {
          utilService.redirect('toolbox');
        }
      } else {
        utilService.redirect('toolbox');
      }
    }
  };

  var redirectToPage = function(page) {
    var pageAccessible = false;
    switch (page) {
      case 'dashboard': {
        pageAccessible = !!profile.hasDashboardTab;
        break;
      }
      case 'academics': {
        pageAccessible = !!profile.hasDashboardTab;
        break;
      }
      case 'finances': {
        pageAccessible = !!profile.hasFinancialsTab;
        break;
      }
      case 'campus': {
        pageAccessible = !!profile.hasCampusTab;
        break;
      }
      case 'toolbox': {
        pageAccessible = true;
        break;
      }
    }
    if (pageAccessible) {
      utilService.redirect(page);
    } else {
      redirectToHome();
    }
  };

  var setFirstLogin = function() {
    profile.firstLoginAt = (new Date()).getTime();
    redirectToHome();
  };

  /*
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
      $http.post('/api/my/record_first_login').then(setFirstLogin);
    // Redirect to the dashboard when you're accessing the root page and are authenticated
    } else if (events.isAuthenticated) {
      redirectToHome();
    }
  };

  var setExtraProperties = function(profile) {
    if (profile.roles) {
      // Set this boolean to true when they only have the applicant role
      var activeRoles = getActiveRoles(profile.roles);
      profile.isApplicantOnly = (_.size(activeRoles) === 1 && activeRoles[0] === 'applicant');
    }

    // Set whether the current user can POST information when acting as someone
    profile.actAsOptions = {
      canPost: !(_.get(profile, 'features.preventActingAsUsersFromPosting') && !profile.isDirectlyAuthenticated),
      canSeeCSLinks: (profile.canSeeCSLinks && !$route.current.isAdvisingStudentLookup)
    };

    return profile;
  };

  /**
   * Returns array of active roles
   * @param  {Object} roles   profile roles object
   * @return {Array}          array of role keys that are true
   */
  var getActiveRoles = function(roles) {
    var activeRoles = [];
    _.forEach(roles, function(value, key) {
      if (value) {
        activeRoles.push(key);
      }
    });
    return activeRoles;
  };

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
   * @return {Object} user information
   */
  var fetch = function(options) {
    httpService.clearCache(options, statusUrl);

    $ngRedux.dispatch(fetchStatusStart());
    return $http.get(statusUrl, {
      cache: true
    }).then(function(xhr) {
      $ngRedux.dispatch(fetchStatusSuccess(xhr.data));
      return handleUserLoaded(xhr.data);
    }).catch(error => {
      $ngRedux.dispatch(fetchStatusFailure({ status: error.status, statusText: error.statusText }));
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

  var signIn = function() {
    analyticsService.sendEvent('Authentication', 'Redirect to login');
    window.location = '/auth/cas';
  };

  /**
   * Remove OAuth permissions for a service for the currently logged in user
   * @param {String} authorizationService The authorization service (e.g. 'google')
   * @return {undefined}
   */
  var removeOAuth = function(authorizationService) {
    // Send the request to remove the authorization for the specific OAuth service
    // Only when the request was successful, we update the UI
    $http.post('/api/' + authorizationService.toLowerCase() + '/remove_authorization').then(
      function successCallback() {
        analyticsService.sendEvent('OAuth', 'Remove', 'service: ' + authorizationService);
        profile['has' + authorizationService + 'AccessToken'] = false;
      }
    );
  };

  var signOut = function() {
    $http.post('/logout').then(
      function successCallback(response) {
        if (response.data && response.data.redirectUrl) {
          analyticsService.sendEvent('Authentication', 'Redirect to logout');
          window.location = response.data.redirectUrl;
        }
      },
      function errorCallback(response) {
        if (response && response.status === 401) {
          // User is already logged out
          window.location = '/';
        }
      }
    );
  };

  // Expose methods
  return {
    enableOAuth: enableOAuth,
    events: events,
    fetch: fetch,
    handleAccessToPage: handleAccessToPage,
    handleRouteChange: handleRouteChange,
    handleUserLoaded: handleUserLoaded,
    profile: profile,
    redirectToHome: redirectToHome,
    redirectToPage: redirectToPage,
    removeOAuth: removeOAuth,
    setFirstLogin: setFirstLogin,
    signIn: signIn,
    signOut: signOut
  };
});
