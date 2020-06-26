import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';
import { react2angular } from 'react2angular';

import { connect } from 'react-redux';
import ReduxProvider from 'React/components/ReduxProvider';

import './DegreeProgressLinks.scss';

const commonPropTypes = {
  aprLink: PropTypes.object,
  degreePlannerLink: PropTypes.object,
  showPnpCalculator: PropTypes.func,
  showPnpCalculatorLink: PropTypes.bool,
  isAdvisingStudentLookup: PropTypes.bool,
};

const DegreeProgressLinks = ({
  aprLink,
  degreePlannerLink,
  showPnpCalculator,
  showPnpCalculatorLink,
  isAdvisingStudentLookup,
}) => {
  return (
    <>
      {aprLink && (
        <>
          <div className="linksTitle icon iconApr">
            Academic Progress Report
          </div>
          <div className="linksSubTitle">
            Confirm completion of requirements to date
          </div>
          <APILink {...aprLink} />
        </>
      )}
      {degreePlannerLink && (
        <>
          <div className="linksTitle icon iconDegreePlanner">
            Degree Planner
          </div>
          <div className="linksSubTitle">Create a long-term program plan</div>
          <APILink {...degreePlannerLink} />
        </>
      )}
      {showPnpCalculatorLink && (
        <>
          <div className="linksTitle icon iconGradeEstimator">
            1/3 Passed Grade Estimator
          </div>
          <div>
            <button
              className="cc-button-link"
              onClick={() => showPnpCalculator()}
              disabled={isAdvisingStudentLookup}
            >
              Estimate 1/3 PNP unit limits
            </button>
            {isAdvisingStudentLookup && (
              <div>
                Use View-As to see this student&apos;s Passed(P) Grade Limit and
                use the estimator.
              </div>
            )}
          </div>
        </>
      )}
    </>
  );
};

DegreeProgressLinks.displayName = 'DegreeProgressLinks';
DegreeProgressLinks.propTypes = commonPropTypes;

const ConnectedDegreeProgressLinks = connect()(DegreeProgressLinks);

const DegreeProgressLinksContainer = props => {
  return (
    <ReduxProvider>
      <ConnectedDegreeProgressLinks {...props} />
    </ReduxProvider>
  );
};

DegreeProgressLinksContainer.propTypes = commonPropTypes;

angular
  .module('calcentral.react')
  .component(
    'degreeProgressLinks',
    react2angular(DegreeProgressLinksContainer)
  );
