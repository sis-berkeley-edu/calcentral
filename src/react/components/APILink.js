import React from 'react';
import PropTypes from 'prop-types';
import qs from 'querystringify';
import { connect } from 'react-redux';
import VisuallyHidden from './VisuallyHidden';
import './APILink.scss';

const propTypes = {
  disabled: PropTypes.bool,
  isCsLink: PropTypes.bool,
  name: PropTypes.string,
  showNewWindow: PropTypes.bool,
  title: PropTypes.string,
  ucFrom: PropTypes.string,
  ucFromLink: PropTypes.string,
  ucFromText: PropTypes.string,
  ucUpdateCache: PropTypes.string,
  url: PropTypes.string,
  urlId: PropTypes.string,
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
  disabled,
  isCsLink,
  name,
  showNewWindow,
  title,
  url,
  ucFromLink,
  ucFromText,
  ucUpdateCache,
}) => {
  if (!url) {
    return null;
  }
  if (disabled) {
    return <span className="APILink APILink--disabled">{name}</span>;
  }

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
  const target = showNewWindow ? '_blank' : '_self';
  const rel = showNewWindow ? 'noopener noreferrer' : null;

  return (
    <a
      href={href}
      title={title}
      target={target}
      rel={rel}
      onClick={e => e.stopPropagation()}
    >
      {name}
      {showNewWindow && <VisuallyHidden>{visuallyHiddenText}</VisuallyHidden>}
    </a>
  );
};

APILink.propTypes = propTypes;

const mapStateToProps = ({
  currentRoute: { name: ucFromText, url: ucFromLink },
}) => {
  return { ucFromText, ucFromLink };
};

export default connect(mapStateToProps)(APILink);
