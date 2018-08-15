'use strict';

angular.module('calcentral.directives').directive('ccExpandableLinkListDirective', function(widgetService) {
  return {
    restrict: 'E',
    scope: {
      links: '=',
      sectionTitle: '='
    },
    templateUrl: 'directives/expandable_link_list.html',
    link: function(scope) {
      scope.toggleShow = widgetService.toggleShow;
      scope.section = {};
    }
  };
});
