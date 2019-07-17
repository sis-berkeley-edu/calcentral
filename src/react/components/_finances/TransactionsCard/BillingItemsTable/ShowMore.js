import React from 'react';
import PropTypes from 'prop-types';

import DisclosureChevron from 'react/components/DisclosureChevron';

import './ShowMore.scss';

const ShowMore = ({ expanded, onClick }) => (
  <div className="ShowMore" onClick={onClick}>
    <span className="ShowMore__message">
      { expanded ? 'Show Less' : 'Show More' }
    </span>
    <DisclosureChevron expanded={expanded} />
  </div>
);
ShowMore.propTypes = {
  expanded: PropTypes.bool,
  onClick: PropTypes.func
};

export default ShowMore;
