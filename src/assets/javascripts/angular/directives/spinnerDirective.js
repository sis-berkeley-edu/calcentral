'use strict';

/**
 * This attribute will replace the element by a spinner until data is returned in an HTTP respsonse.
 */
angular.module('calcentral.directives').directive('ccSpinnerDirective', function() {
  return {
    restrict: 'A',
    link: function(scope, elment, attrs) {
      scope.isLoading = true;

      // Make sure we don't interupt the screenreader
      attrs.$set('aria-live', 'polite');

      if (attrs.ccSpinnerDirectiveMessage) {
        var messageTemplate = '<p class="cc-spinner-message">' + attrs.ccSpinnerDirectiveMessage + '</p>';
        var messageElement = angular.element(messageTemplate);
      }

      /**
       * Check whether isLoading has changed
       */
      var watch = function(value) {
        attrs.$set('aria-busy', value);
        elment.toggleClass('cc-spinner', value);

        if (attrs.ccSpinnerDirectiveMessage) {
          if (value) {
            elment.after(messageElement);
          } else {
            messageElement.remove();
          }
        }
      };

      // This allows us to watch for a different variable than isLoading
      // We need this when we're using ngInclude
      if (attrs.ccSpinnerDirective) {
        scope.$watch(attrs.ccSpinnerDirective, watch);
      } else {
        scope.$watch('isLoading', watch);
      }
    }
  };
});
