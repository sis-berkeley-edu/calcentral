require('../angularlib/swipeDirective');

import store from 'Redux/store';
import { setConfig } from 'Redux/actions/configActions';

// Initialize all of the submodules
angular.module('calcentral.config', ['ngRoute']);
angular.module('calcentral.controllers', ['ngRedux']).config($ngReduxProvider => {
  $ngReduxProvider.provideStore(store);
}).run(function($ngRedux, calcentralConfig) {
  $ngRedux.dispatch(setConfig(calcentralConfig));
});

angular.module('calcentral.directives', []);
angular.module('calcentral.factories', []);
angular.module('calcentral.filters', []);
angular.module('calcentral.react', []);
angular.module('calcentral.services', ['ng']);
angular.module('templates', []);

// CalCentral module
angular.module('calcentral', [
  'calcentral.config',
  'calcentral.controllers',
  'calcentral.directives',
  'calcentral.factories',
  'calcentral.filters',
  'calcentral.react',
  'calcentral.services',
  'ngRoute',
  'ngSanitize',
  'ngTouch',
  'templates',
  'ngRedux'
]);

// Configure the ngRedux to use the shared store
angular.module('calcentral').config($ngReduxProvider => {
  $ngReduxProvider.provideStore(store);
});

// Inject the CalCentral config as a constant that can be use accross modules
var injectConfigConstant = function(response) {
  angular.module('calcentral.config').constant('calcentralConfig', response.data);
};

// Bootstrap the CalCentral Angular App
var bootstrap = function() {
  angular.element(document).ready(function() {
    angular.bootstrap(document, ['calcentral']);
  });
};

// Load the CalCentral config which includes: csrf tokens, uid, google analytics id, app version, hostname
var loadConfig = function() {
  console.log('This is the Tomcat comparison version');

  var initInjector = angular.injector(['ng']);
  var $http = initInjector.get('$http');

  const promise = $http.get('/api/config');

  const onFailure = (response) => {
    const {
      status,
      data: { url } = {}
    } = response;

    if (status === 401) {
      window.location = url;
    }
  };

  promise.then(null, onFailure);

  return promise;
};

loadConfig().then(injectConfigConstant).then(bootstrap);
