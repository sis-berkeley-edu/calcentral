'use strict';

angular.module('calcentral.services').service('authService', function($http, $route, $timeout, $window, analyticsService, calcentralConfig) {
  /*
   * Check whether the current user is logged in or not
   * If they aren't AND they aren't on a public page, redirect them to login.
   */
  var isLoggedInRedirect = function() {
    // We need a $timeout since we need to wait for the DOM to be ready
    // otherwise the back button doesn't trigger a new response
    $timeout(function() {
      $http.get('/api/my/am_i_logged_in').then(
        function successCallback(response) {
          if (response.data && !response.data.amILoggedIn && $route && $route.current && !$route.current.isPublic) {
            signIn();
          }
        }
      );
    }, 0);
  };

  var signIn = function() {
    analyticsService.sendEvent('Authentication', 'Redirect to login');

    var form = $window.document.createElement('form');
    form.setAttribute('method', 'post');
    form.setAttribute('action', '/auth/cas');

    var hiddenField = document.createElement('input');
    hiddenField.setAttribute('name', 'authenticity_token');
    hiddenField.setAttribute('value', calcentralConfig.csrfToken);
    hiddenField.setAttribute('type', 'hidden');
    form.appendChild(hiddenField);

    $window.document.body.appendChild(form);
    form.submit();
  };

  return {
    isLoggedInRedirect: isLoggedInRedirect,
    signIn: signIn
  };
});
