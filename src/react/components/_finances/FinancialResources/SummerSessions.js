import React, { useState } from 'react';
import PropTypes from 'prop-types';
import APILink from 'React/components/APILink';
import HasAccessTo from './HasAccessTo';
import FinancialResourcesCategoryHeader from './FinancialResourcesCategoryHeader';
import './FinancialResources.scss';

const SummerSessions = ({ links, getLink, expanded, sirStatus }) => {
  const [isExpanded, setIsExpanded] = useState(expanded);

  const isUndergradSir = sirStatus.sirStatuses
    ? sirStatus.sirStatuses.some(sirStatus => {
        return sirStatus.config.ucSirImageCd === 'UGRD';
      })
    : false;

  return (
    <HasAccessTo
      linkNames={[
        'summerFees',
        'summerCancelWithdraw',
        'summerSchedule',
        'summerWebsite',
        'summerEstimator',
      ]}
      links={links}
    >
      <div
        className="FinancialResources__categoryContainer"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <FinancialResourcesCategoryHeader
          title="Summer Sessions"
          expanded={isExpanded}
        />
        {isExpanded && (
          <ul className="FinancialResources">
            <HasAccessTo linkNames={['summerFees']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('summerFees', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['summerCancelWithdraw']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('summerCancelWithdraw', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['summerSchedule']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('summerSchedule', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['summerWebsite']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('summerWebsite', links)} />
                </li>
              )}
            </HasAccessTo>
            {/* Summer Estimator is available to users who have an UGRD Sir, 
                but may not have any other attributes required to access the link */}
            {isUndergradSir && links && (
              <li>
                <APILink {...getLink('summerEstimator', links)} />
                <div className="FinancialResources__subText">
                  Estimate your cost and financial aid for Summer Sessions,
                  Summer Abroad, or Global Internships
                </div>
              </li>
            )}
            {!isUndergradSir && (
              <HasAccessTo linkNames={['summerEstimator']} links={links}>
                {links && (
                  <li>
                    <APILink {...getLink('summerEstimator', links)} />
                    <div className="FinancialResources__subText">
                      Estimate your cost and financial aid for Summer Sessions,
                      Summer Abroad, or Global Internships
                    </div>
                  </li>
                )}
              </HasAccessTo>
            )}
          </ul>
        )}
      </div>
    </HasAccessTo>
  );
};

SummerSessions.propTypes = {
  expanded: PropTypes.bool,
  getLink: PropTypes.func,
  sirStatus: PropTypes.object,
  links: PropTypes.object,
};

export default SummerSessions;
