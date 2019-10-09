/**
 * Interface to Google Analytics
 * More info on https://developers.google.com/analytics/devguides/collection/analyticsjs/events
 *
 * The analyticsService initializes Google Analytics and sends the page view
 * event with each AngularJS routed page change. Thus this class expects
 * 'window.ga' to be present already.
 * @param {String} applicationLayer Rails application mode (e.g. 'production', 'development')
 */
export class googleAnalytics {
  constructor(applicationLayer) {
    this.applicationLayer = applicationLayer;
  }

  isProduction() {
    return this.applicationLayer === 'production';
  }

  /**
   * Send an analytics event
   * @param {String} category e.g. Video
   * @param {String} action e.g. Play
   * @param {String} label e.g. Flying to Belgium
   * @return {undefined}
   * More info on https://developers.google.com/analytics/devguides/collection/analyticsjs/events
   */
  sendEvent(category, action, label) {
    if (this.isProduction()) {
      window.ga('send', 'event', category, action, label);
    }
  }

  /**
   * Track when there is an external link being clicked
   * @param {String} section The section you're currently in (e.g. Up Next / My Classes / Activity)
   * @param {String} website The website you're trying to access (Google Maps)
   * @param {String} url The URL you're accessing
   * @return {undefined}
   */
  trackExternalLink(section, website, url) {
    this.sendEvent(
      'External link',
      url,
      'section: ' + section + ' - website: ' + website
    );
  }
}
