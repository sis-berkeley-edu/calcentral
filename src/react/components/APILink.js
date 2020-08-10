import React from 'react';
import PropTypes from 'prop-types';
import qs from 'querystringify';
import { connect } from 'react-redux';
import { googleAnalytics } from 'functions/googleAnalytics';
import VisuallyHidden from './VisuallyHidden';
import './APILink.scss';

const propTypes = {
  children: PropTypes.node,
  disabled: PropTypes.bool,
  isCampusSolutionsLink: PropTypes.bool,
  isCsLink: PropTypes.bool,
  name: PropTypes.node,
  showNewWindow: PropTypes.bool,
  title: PropTypes.string,
  ucFrom: PropTypes.string,
  ucFromLink: PropTypes.string,
  ucFromText: PropTypes.string,
  ucUpdateCache: PropTypes.string,
  url: PropTypes.string,
  urlId: PropTypes.string,
  className: PropTypes.string,
  style: PropTypes.object,
  applicationLayer: PropTypes.string,
  gaSection: PropTypes.string,
};

const visuallyHiddenText = ', this link opens in new window';

// the ucFromLink value may need to have a 'ucUpdateCache' parameter appended to it,
// if we get the value from the Link API the following will append it to the ucFromLink
const returnURL = (url, updateCache) => {
  const queryStringPrefixFromLink = url.includes('?') ? '&' : true;
  return updateCache && !url.includes('ucUpdateCache')
    ? url +
        qs.stringify({ ucUpdateCache: updateCache }, queryStringPrefixFromLink)
    : url;
};

const APILink = ({
  children,
  disabled,
  isCampusSolutionsLink,
  isCsLink,
  name,
  showNewWindow,
  title,
  url,
  urlId,
  ucFromLink,
  ucFromText,
  ucUpdateCache,
  style,
  className,
  applicationLayer,
  gaSection = '',
}) => {
  if (!url) {
    return null;
  }
  if (disabled) {
    return <span className="APILink APILink--disabled">{name}</span>;
  }

  const ga = new googleAnalytics(applicationLayer);
  const trackLinkEvent = event => {
    event.stopPropagation();
    if (isCampusSolutionsLink) {
      ga.sendEvent(
        'Open BCS page',
        'Click',
        'section: ' + gaSection + ' - csLinkId: ' + urlId
      );
    } else {
      ga.trackExternalLink(gaSection, title);
    }
  };

  const queryStringPrefix = url.includes('?') ? '&' : true;
  const href = isCsLink
    ? url +
      qs.stringify(
        {
          ucFrom: 'CalCentral',
          ucFromText: ucFromText,
          ucFromLink: returnURL(ucFromLink, ucUpdateCache),
        },
        queryStringPrefix
      )
    : url;
  const target = showNewWindow || !isCsLink ? '_blank' : '_self';
  const rel = showNewWindow || !isCsLink ? 'noopener noreferrer' : null;

  return (
    <a
      href={href}
      title={title}
      target={target}
      rel={rel}
      onClick={e => trackLinkEvent(e)}
      className={className}
      style={style}
    >
      {children || name}
      {showNewWindow && <VisuallyHidden>{visuallyHiddenText}</VisuallyHidden>}
    </a>
  );
};

APILink.propTypes = propTypes;

const mapStateToProps = ({
  config: { applicationLayer },
  currentRoute: { name: ucFromText, url: ucFromLink },
}) => {
  return { applicationLayer, ucFromText, ucFromLink };
};

export default connect(mapStateToProps)(APILink);
