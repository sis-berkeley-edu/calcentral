'use strict';



angular.module('calcentral.directives').directive('ccProfileImageDirective', function() {
  return {
    scope: {
      name: '=',
      uid: '='
    },
    templateUrl: 'widgets/profile_img.html'
  };
});
