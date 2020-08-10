import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';
import { react2angular } from 'react2angular';

import { connect } from 'react-redux';
import ReduxProvider from 'React/components/ReduxProvider';

import './DegreeProgressLinks.scss';

const commonPropTypes = {
  aprLink: PropTypes.object,
  aprFaqsLink: PropTypes.object,
  aprWhatIfLink: PropTypes.object,
  degreePlannerLink: PropTypes.object,
  showPnpCalculator: PropTypes.func,
  showPnpCalculatorLink: PropTypes.bool,
  isAdvisingStudentLookup: PropTypes.bool,
};

const DegreeProgressLinks = ({
  aprLink,
  aprFaqsLink,
  aprWhatIfLink,
  degreePlannerLink,
  showPnpCalculator,
  showPnpCalculatorLink,
  isAdvisingStudentLookup,
}) => {
  return (
    <>
      {aprLink && (
        <div className="linkContainer">
          <div className="linkTitle icon iconApr">
            Academic Progress Report
          </div>

          {aprLink.linkDescriptionDisplay && (
            <div className="linkSubTitle linkSubText">
              {aprLink.linkDescription + ' '}
              {aprFaqsLink && (
                <APILink {...aprFaqsLink} />
              )}
            </div>
          )}
          <div className="linkSubText">
            <APILink gaSection="Degree Progress" {...aprLink} />
          </div>
        </div>
      )}
      {degreePlannerLink && (
        <div className="linkContainer">
          <div className="linkTitle icon iconDegreePlanner">
            Degree Planner
          </div>
          {degreePlannerLink.linkDescriptionDisplay && (
            <div className="linkSubTitle linkSubText">
              {degreePlannerLink.linkDescription}
            </div>
          )}
          <div className="linkSubText">
            <APILink {...degreePlannerLink} />
          </div>
        </div>
      )}
      {aprWhatIfLink && (
        <div className="linkContainer">
          <div className="linkTitle icon iconAprWhatIf">
            What-if Academic Progress Report
          </div>
          {aprWhatIfLink.linkDescriptionDisplay && (
            <div className="linkSubTitle linkSubText">
              {aprWhatIfLink.linkDescription}
            </div>
          )}
          <div className="linkSubText">
            <APILink gaSection="Degree Progress" {...aprWhatIfLink} />
          </div>
        </div>
      )}
      {showPnpCalculatorLink && (
        <>
          <div className="linkTitle icon iconGradeEstimator">
            1/3 Passed Grade Estimator
          </div>
          <div className="linkSubText">
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
