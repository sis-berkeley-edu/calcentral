import React from 'react';
import PropTypes from 'prop-types';
import qs from 'querystringify';
import './APILink.scss';

const propTypes = {
  disabled: PropTypes.bool,
  isCsLink: PropTypes.bool,
  name: PropTypes.string,
  title: PropTypes.string,
  ucFrom: PropTypes.string,
  ucFromLink: PropTypes.string,
  ucFromText: PropTypes.string,
  url: PropTypes.string,
  urlId: PropTypes.string
};

const APILink = ({ disabled, title, name, url, ucFrom, ucFromText }) => {
  if (disabled) {
    return <span className="APILink APILink--disabled">{name}</span>;
  }

  const currentUrl = window.location.href;
  const queryStringPrefix = url.includes('?') ? '&' : true;
  const href = url + qs.stringify({
    ucFrom,
    ucFromText,
    ucFromLink: currentUrl
  }, queryStringPrefix);

  return (
    <a href={href} title={title} onClick={(e) => e.stopPropagation()}>
      {name}
    </a>
  );
};

APILink.propTypes = propTypes;

export default APILink;
