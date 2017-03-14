(function(window, $) {
  'use strict';

  window.CALCENTRAL = 'https://junction.berkeley.edu';

  // Ensure the bCourses development and test servers are pointing to the correct
  // CalCentral instance when a copy of production is made
  if (window.location.origin === 'https://ucberkeley.beta.instructure.com') {
    window.CALCENTRAL = 'https://junction-dev.berkeley.edu';
  } else if (window.location.origin === 'https://ucberkeley.test.instructure.com') {
    window.CALCENTRAL = 'https://junction-qa.berkeley.edu';
  }

  // Load the JavaScript customizations
  $.getScript(window.CALCENTRAL + '/canvas/canvas-customization.js');

  // Load the CSS customizations
  var css = $('<link>', {
    'rel': 'stylesheet',
    'type': 'text/css',
    'href': window.CALCENTRAL + '/canvas/canvas-customization.css'
  });
  $('head').append(css);

})(window, window.$);
