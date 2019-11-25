import { googleAnalytics } from 'functions/googleAnalytics';

/**
 * Changes to location to begin Oauth service authorization request
 * @param {String} authorizationService The authorization service (e.g. 'google')
 * @return {undefined}
 */
export const enableOAuth = (authorizationService, applicationLayer) => {
  const ga = new googleAnalytics(applicationLayer);
  ga.sendEvent('OAuth', 'Enable', 'service: ' + authorizationService);
  window.location =
    '/api/' + authorizationService.toLowerCase() + '/request_authorization';
};

export default enableOAuth;
