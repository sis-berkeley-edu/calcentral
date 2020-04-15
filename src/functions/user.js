import { googleAnalytics } from 'functions/googleAnalytics';

/**
 * Changes to location to begin Oauth service authorization request
 * @param {String} authorizationService The authorization service (e.g. 'google')
 * @return {undefined}
 */
export const authorizeGoogleAccess = (applicationLayer) => {
  const ga = new googleAnalytics(applicationLayer);
  ga.sendEvent('OAuth', 'Enable', 'service: Google');
  window.location = '/api/google/request_authorization';
};

export default authorizeGoogleAccess;
