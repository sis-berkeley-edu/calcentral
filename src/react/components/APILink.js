import React from 'react';
import PropTypes from 'prop-types';
import qs from 'querystringify';

const propTypes = {
  isCsLink: PropTypes.bool,
  name: PropTypes.string,
  title: PropTypes.string,
  ucFrom: PropTypes.string,
  ucFromLink: PropTypes.string,
  ucFromText: PropTypes.string,
  url: PropTypes.string,
  urlId: PropTypes.string
};

const APILink = ({ title, name, url, ucFrom, ucFromText }) => {
  const currentUrl = window.location.href;

  const href = url + qs.stringify({
    ucFrom,
    ucFromText,
    ucFromLink: currentUrl  
  }, true);

  return (
    <a href={href} title={title}>
      {name}
    </a>
  );
};

APILink.propTypes = propTypes;

export default APILink;
