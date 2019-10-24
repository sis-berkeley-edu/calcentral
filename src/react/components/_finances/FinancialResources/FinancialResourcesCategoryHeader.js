import React from 'react';
import PropTypes from 'prop-types';

import DisclosureChevron from 'react/components/DisclosureChevron';

import './FinancialResources.scss';

const FinancialResourcesCategoryHeader = ({ title, expanded }) => {
  return (
    <h3>
      <DisclosureChevron style={{ marginRight: '5px' }} expanded={expanded} />
      {title}
    </h3>
  );
};

FinancialResourcesCategoryHeader.propTypes = {
  title: PropTypes.string,
  expanded: PropTypes.bool,
};

export default FinancialResourcesCategoryHeader;
