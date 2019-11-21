import React, { useState } from 'react';
import PropTypes from 'prop-types';
import APILink from 'React/components/APILink';
import HasAccessTo from './HasAccessTo';
import FinancialResourcesCategoryHeader from './FinancialResourcesCategoryHeader';
import './FinancialResources.scss';

const FinancialPlanningLiteracy = ({ links, getLink, expanded }) => {
  const [isExpanded, setIsExpanded] = useState(expanded);

  return (
    <HasAccessTo linkNames={['bearsFinancialSuccess', 'iGrad']} links={links}>
      <div className="FinancialResources__categoryContainer">
        <div onClick={() => setIsExpanded(!isExpanded)}>
          <FinancialResourcesCategoryHeader
            title="Financial Planning and Literacy"
            expanded={isExpanded}
          />
        </div>
        {isExpanded && (
          <ul className="FinancialResources">
            <HasAccessTo linkNames={['bearsFinancialSuccess']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('bearsFinancialSuccess', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['iGrad']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('iGrad', links)} />
                </li>
              )}
            </HasAccessTo>
          </ul>
        )}
      </div>
    </HasAccessTo>
  );
};

FinancialPlanningLiteracy.propTypes = {
  expanded: PropTypes.bool,
  getLink: PropTypes.func,
  links: PropTypes.object,
};

export default FinancialPlanningLiteracy;
