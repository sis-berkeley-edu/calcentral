'use strict';

var angular = require('angular');

/**
 * Directive to show a Campus Solutions link
 */
angular.module('calcentral.directives').directive('ccCampusSolutionsLinkItemDirective', function() {
  return {
    templateUrl: 'directives/campus_solutions_link_item.html',
    scope: {
      cache: '@',
      link: '=',
      text: '@',
      disabled: '@'
    }
  };
});
