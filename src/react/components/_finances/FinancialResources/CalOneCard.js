import React, { useState } from 'react';
import PropTypes from 'prop-types';
import APILink from 'React/components/APILink';
import HasAccessTo from './HasAccessTo';
import FinancialResourcesCategoryHeader from './FinancialResourcesCategoryHeader';
import './FinancialResources.scss';

const CalOneCard = ({ links, getLink, expanded }) => {
  const [isExpanded, setIsExpanded] = useState(expanded);

  return (
    <HasAccessTo
      linkNames={['debitAccount', 'mealPlanBalance', 'mealPlanLearn']}
      links={links}
    >
      <div className="FinancialResources__categoryContainer">
        <div onClick={() => setIsExpanded(!isExpanded)}>
          <FinancialResourcesCategoryHeader
            title="Cal 1 Card"
            expanded={isExpanded}
          />
        </div>
        {isExpanded && (
          <ul className="FinancialResources">
            <HasAccessTo linkNames={['debitAccount']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('debitAccount', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['mealPlanBalance']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('mealPlanBalance', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['mealPlanLearn']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('mealPlanLearn', links)} />
                </li>
              )}
            </HasAccessTo>
          </ul>
        )}
      </div>
    </HasAccessTo>
  );
};

CalOneCard.propTypes = {
  expanded: PropTypes.bool,
  getLink: PropTypes.func,
  links: PropTypes.object,
};

export default CalOneCard;
