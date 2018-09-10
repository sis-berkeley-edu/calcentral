'use strict';

angular.module('calcentral.directives').directive('ccCompileDirective', function($compile) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      scope.$watch(attrs.ccCompileDirective,
        function(value) {
          // Value can be undefined, when that's the case set it to an empty string
          // we need to do this since otherwise the html won't be set
          value = value || '';

          // When the 'compile' expression changes assign it into the current DOM
          element.html(value);

          // Compile the new DOM and link it to the current scope.
          // NOTE: we only compile .childNodes so that we don't get into infinite loop compiling ourselves
          // Skip recompilation when there's no work to be done. Falsy values should already be set properly
          // from above.
          if (value) {
            $compile(element.contents())(scope);
          }
        }
      );
    }
  };
});
