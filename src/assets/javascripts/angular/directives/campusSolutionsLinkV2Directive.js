'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Directive for displaying links to Campus Solutions
 *
 * Intended for use with objects that include Campus Solutions Link API properties
 *
 * Example:
 *   {
 *     "name": "Academic Progress Report",
 *     "title": "View this student's Academic Progress Report",
 *     "ccPageName": 'My Academics',
 *     "ccPageUrl": 'http://calcentral.berkeley.edu/academics/',
 *     "ucfrom": true,
 *     "ucfromlink": true,
 *     "ucfromtext": null,
 *     "url": "https://cs-qat.berkeley.edu/psc/bcsqat/EMPLOYEE/PSFT_CS/c/SSR_ADVISEE_OVRD.SAA_SS_DPR_ADB.GBL?EMPLID=12345"
 *     "shownewwindow": true,
 *     "ccCache": 'enrollment'
 *   }
 *
 * Each of the properties are used by the directive as follows:
 *   name - Used as the body (link label) of the anchor tag
 *   title - Used as the title attribute (hover text) for the anchor tag
 *   ccPageName - String representing the name of the current CalCentral page that the user is linking from. Defaults
 *   to 'CalCentral'
 *   ccPageUrl - String representing URL of the current CalCentral page that the user is linking from
 *   ucFrom - When true, the 'ucFrom=CALCENTRAL' parameter is appended to the query string of the CS page URL,
 *     thus activating header/banner on the CS page. Defaults to false.
 *   ucFromLink - When true, the 'ucFromLink' parameter is appended to the query string of the CS page URL, with
 *     'ccPageUrl' as the value. Defaults to the current CalCentral page URL when 'null'. Defaults to false.
 *   ucFromText - When true, the 'ucFromText' parameter is appended to the query string of the CS page URL, with
 *     'ccPageName' as the value. Defaults to 'CalCentral' when 'null'. Defaults to false.
 *   showNewWindow - Allows the default behavior implemented by the outboundLinkDirective.js when true
 *     resulting in links to a non-CalCentral page opening in a new window/tab. Defaults to false.
 *   ccCache - When specified, is included as the value for the 'ucUpdateCache' parameter appended to the CS page URL
 *     query string. Is included with the return link to prompt CalCentral to clear any related caches related
 *     to actions taken by the user within the CS pages
 *
 * In most cases you can simply pass the object to the directive as follows. The page name and URL are passed to the
 * directive explicitly because these are usually set in the AngularJS controller for the page.
 *   <a data-cc-campus-solutions-link-v2-directive="csLinkUrl"></a>
 *
 * Often the page name and URL may need to be passed as an attribute:
 *   <a data-cc-campus-solutions-link-v2-directive="csLinkObject"
 *     data-cc-campus-solutions-link-v2-directive-cc-page-name="{{currentPage.name}}"
 *     data-cc-campus-solutions-link-v2-directive-cc-page-url="{{currentPage.url}}"
 *   ></a>
 *
 * If needed, any of the attributes may specified to override the property of the same name in the link object.
 * If you are needing to manually configure CS links, you can specify a value of 'true' instead of passing a
 * CS Link Object to the directive, specifying all the other values as needed.
 *   <a
 *     data-cc-campus-solutions-link-v2-directive="true"
 *     data-cc-campus-solutions-link-v2-directive-cc-cache="enrollment"
 *     data-cc-campus-solutions-link-v2-directive-cc-page-name="My Academics"
 *     data-cc-campus-solutions-link-v2-directive-cc-page-url="{{alternativeUrl}}"
 *     data-cc-campus-solutions-link-v2-directive-name="Progress Report"
 *     data-cc-campus-solutions-link-v2-directive-show-new-window="true"
 *     data-cc-campus-solutions-link-v2-directive-title="View the AP Report"
 *     data-cc-campus-solutions-link-v2-directive-uc-from="true"
 *     data-cc-campus-solutions-link-v2-directive-uc-from-link="false"
 *     data-cc-campus-solutions-link-v2-directive-uc-from-text="false"
 *     data-cc-campus-solutions-link-v2-directive-url="csLinkUrl"
 *   ></a>
 *
 * If the HTML element using the directive has a body present, this body will not be replaced.
 *   <a data-cc-campus-solutions-link-v2-directive="csLinkObject">My Custom Link Body</a>
 *
 */
angular.module('calcentral.directives').directive('ccCampusSolutionsLinkV2Directive', function(linkService) {

  /**
   * Sets the text for the anchor tag if not already present
   */
  var setLinkBody = function(linkBody, element) {
    if (linkBody) {
      var currentLinkBody = element.text();
      if (_.isEmpty(currentLinkBody)) {
        element.text(linkBody);
      }
    }
  };

  /**
   * Prepares object used to configure the link.
   * Provides logic for element attributes overriding link object properties
   *
   * @param  {Object} linkObj Link object originating from the Campus Solutions Link API
   * @param  {Object} scope   AngularJS scope object
   * @param  {Object} attrs   Attributes object for the element the directive being processed is applied to
   * @return {Object}         Link configuration object
   */
  var getLinkConfig = function(linkObj, scope, attrs) {
    var baseLinkUrl = scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveUrl) || _.get(linkObj, 'url');
    var includeUcFrom = !!(scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveUcFrom) || _.get(linkObj, 'ucfrom'));
    var includeUcFromLink = !!(scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveUcFromLink) || _.get(linkObj, 'ucfromlink'));
    var includeUcFromText = !!(scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveUcFromText) || _.get(linkObj, 'ucfromtext'));
    var ccCacheString = attrs.ccCampusSolutionsLinkV2DirectiveCcCache || _.get(linkObj, 'ccCache');
    var ccPageName = scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveCcPageName) || _.get(linkObj, 'ccPageName') || 'CalCentral';
    var ccPageUrl = scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveCcPageUrl) || _.get(linkObj, 'ccPageUrl');
    var decoratedLinkUrl = decorateLink(baseLinkUrl, includeUcFrom, includeUcFromLink, includeUcFromText, ccCacheString, ccPageName, ccPageUrl);

    // TODO: Discover why link objects either include 'showNewwindow' or 'shownewwindow' property
    var showNewWindow = scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveShowNewWindow) || _.get(linkObj, 'shownewwindow') || _.get(linkObj, 'showNewWindow') || false;
    var linkBody = scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveName) || _.get(linkObj, 'name');
    var linkHoverText = scope.$eval(attrs.ccCampusSolutionsLinkV2DirectiveTitle) || _.get(linkObj, 'title') || false;

    return {
      linkBody: linkBody,
      linkHoverText: linkHoverText,
      linkUrl: decoratedLinkUrl,
      showNewWindow: showNewWindow
    };
  };

  /**
   * Applies ucFrom, ucFromLink, and ucFromText parameters to URL
   * 'ucFrom' is always 'CalCentral'
   */
  var decorateLink = function(linkUrl, includeUcFrom, includeUcFromLink, includeUcFromText, ccCacheString, ccPageName, ccPageUrl) {
    if (/^http/.test(linkUrl) && includeUcFrom === true) {
      linkUrl = linkService.fixLastQuestionMark(linkUrl);

      if (includeUcFrom) {
        linkUrl = linkService.updateQueryStringParameter(linkUrl, 'ucFrom', 'CalCentral');
      }
      if (includeUcFromText) {
        linkUrl = linkService.updateQueryStringParameter(linkUrl, 'ucFromText', ccPageName);
      }
      if (includeUcFromLink) {
        if (ccCacheString) {
          ccPageUrl = linkService.updateQueryStringParameter(ccPageUrl, 'ucUpdateCache', ccCacheString);
        }
        var urlEncodedCcPageUrl = encodeURIComponent(ccPageUrl);
        linkUrl = linkService.updateQueryStringParameter(linkUrl, 'ucFromLink', urlEncodedCcPageUrl);
      }
    }
    return linkUrl;
  };

  return {
    // It needs to run after the attributes are interpolated, and outboundLinkDirective linking is applied (for new window processing)
    priority: 99,
    restrict: 'A',
    link: function(scope, element, attrs) {
      scope.$watch(attrs.ccCampusSolutionsLinkV2Directive, function(linkObj) {
        var linkConfig = getLinkConfig(linkObj, scope, attrs);

        attrs.$set('href', linkConfig.linkUrl);
        if (linkConfig.linkHoverText) {
          attrs.$set('title', linkConfig.linkHoverText);
        }
        setLinkBody(linkConfig.linkBody, element);

        // respect if ccOutboundEnabled manually set
        if ((attrs.ccOutboundEnabled === undefined || attrs.ccOutboundEnabled === false) && linkConfig.showNewWindow) {
          linkService.makeOutboundlink(element);
        }
      });
    }
  };
});
