'use strict';



/**
 * Set a scope flag to signal an error during ng-load, enabling fallback to a default image.
 */
angular.module('calcentral.directives').directive('ccLoadErrorDirective', function() {
  return {
    link: function(scope, elm, attrs) {
      elm.bind('error', function() {
        scope.$apply(function() {
          // Defensive programming, in case of failed calls to photo APIs which
          // cause the photo field not to be initialized on the scope of its
          // respective controller.
          var context = scope[attrs.ccLoadErrorDirective];
          if (context) {
            context.loadError = true;
          }
        });
      });
    }
  };
});
