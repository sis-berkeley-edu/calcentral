import _ from 'lodash';

/*
  * Add the page name and url to a link object
  * Designed for use on objects used with ccCampusSolutionsLinkDirective to include current page name and URL
  */
export function addCurrentPagePropertiesToLink(link, pageName, pageUrl) {
  link.ccPageName = pageName;
  link.ccPageUrl = pageUrl;
  return link;
}

/*
  * Adds the current page name and URL to each object in a resource collection
  * Designed for use on objects used with ccCampusSolutionsLinkDirective
  */
export function addCurrentPagePropertiesToResources(resources, pageName, pageUrl) {
  return _.mapValues(resources, resource => addCurrentPagePropertiesToLink(resource, pageName, pageUrl));
}

/*
  * Sometimes Campus Solutions gives us links that end with a question mark, we should clean those up
  * /EMPLOYEE/HRMS/c/MAINTAIN_SERVICE_IND_STDNT.ACTIVE_SRVC_INDICA.GBL?
*/
export function fixLastQuestionMark(link) {
  if (link.indexOf('?', link.length - 1) !== -1) {
    link = link.slice(0, -1);
  }
  return link;
}

/**
 * Update a querystring parameter
 * We'll add it when there is none and update it when there is
 * @param {String} uri The URI you want to update
 * @param {String} key The key of the param you want to update
 * @param {String} value The value of the param you want to update
 * @return {String} The updated URI
 */
export function updateQueryStringParameter(uri, key, value) {
  const re = new RegExp('([?&])' + key + '=.*?(&|$)', 'i');
  const separator = uri.indexOf('?') !== -1 ? '&' : '?';
  if (uri.match(re)) {
    return uri.replace(re, '$1' + key + '=' + value + '$2');
  } else {
    return uri + separator + key + '=' + value;
  }
}

