import React from 'react';
import PropTypes from 'prop-types';
import VisuallyHidden from 'react/components/VisuallyHidden';

import { connect } from 'react-redux';
import { googleAnalytics } from 'functions/googleAnalytics';

const ClassNotesLink = ({ href, applicationLayer }) => {
  const ga = new googleAnalytics(applicationLayer);

  const onClick = event => {
    event.stopPropagation();
    ga.trackExternalLink('Class Information Card', 'View Class Notes');
  };

  return (
    <a href={href} target="_blank" rel="noopener noreferrer" onClick={onClick}>
      View Class Notes
      <VisuallyHidden>, this link opens in new window</VisuallyHidden>
    </a>
  );
};

ClassNotesLink.propTypes = {
  href: PropTypes.string,
  applicationLayer: PropTypes.string,
};

const mapStateToProps = ({ config: { applicationLayer } }) => {
  return { applicationLayer };
};

export default connect(mapStateToProps)(ClassNotesLink);
