import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import CampusSolutionsLinkContainer from '../../CampusSolutionsLink/CampusSolutionsLinkContainer';

import './SectionIncompleteGradingStatus.scss';

const propTypes = {
  academicGuideGradesPolicyLink: PropTypes.object.isRequired,
  gradingBasis: PropTypes.string.isRequired,
  gradingLapseDeadline: PropTypes.string,
  gradingLapseDeadlineDisplay: PropTypes.bool.isRequired,
  lapseDateDisplayColumnIndex: PropTypes.number.isRequired,
  frozenDisplayColumnIndex: PropTypes.number.isRequired,
  totalColumns: PropTypes.number,
};

/**
 * Component for displaying a sections incomplete grading status
 *
 * Note: When updating this component, please also update academicSectionIncompleteGradingStatus
 * which shares this functionality.
 *
 * React2Angular components do not work properly within ng-repeat-start and ng-repeat-end loops,
 * so an AngularJS directive was needed.
 *
 * TODO: Replace with this component once all cards using academicSectionIncompleteGradingStatus
 * have been refactored into React components.
 */
const SectionIncompleteGradingStatus = ({
  academicGuideGradesPolicyLink,
  gradingBasis,
  gradingLapseDeadline,
  gradingLapseDeadlineDisplay,
  lapseDateDisplayColumnIndex,
  frozenDisplayColumnIndex,
  totalColumns}) => {

  const showGradingLapseDeadline = (gradingLapseDeadlineDisplay && gradingLapseDeadline);
  const gradingBasisIsFrozen = (gradingBasis === 'FRZ');
  const columnIndexes = [...Array(totalColumns).keys()];
  const showSingleColumn = (showGradingLapseDeadline && lapseDateDisplayColumnIndex === 0) || (gradingBasisIsFrozen && frozenDisplayColumnIndex === 0);
  const displayColumnIndex = (showGradingLapseDeadline && lapseDateDisplayColumnIndex) || (gradingBasisIsFrozen && frozenDisplayColumnIndex);

  const showStatus = () => {
    return (
      <>
        {showGradingLapseDeadline &&
          <>
            <CampusSolutionsLinkContainer linkObj={academicGuideGradesPolicyLink}>Student Completion Deadline is 30 days before</CampusSolutionsLinkContainer>
            {': ' + gradingLapseDeadline}
          </>
        }
        {gradingBasisIsFrozen &&
          <CampusSolutionsLinkContainer linkObj={academicGuideGradesPolicyLink}>Frozen</CampusSolutionsLinkContainer>
        }
      </>
    )
  };

  if (showGradingLapseDeadline || gradingBasisIsFrozen) {
    return (
      <tr>
        {showSingleColumn &&
          <td className="SectionIncompleteGradingStatus__table_cell" colSpan={totalColumns}>
            {showStatus()}
          </td>
        }
        {!showSingleColumn && columnIndexes.map(index => (
          <td className="SectionIncompleteGradingStatus__table_cell" key={index}>
            {(displayColumnIndex == index) && showStatus()}
            {(displayColumnIndex !== index) && '\u00A0'}
          </td>
        ))}
      </tr>
    );
  } else {
    return null;
  }
};

SectionIncompleteGradingStatus.propTypes = propTypes;

const mapStateToProps = ({ myAcademics }) => {
  const {
    studentLinks: { academicGuideGradesPolicy: academicGuideGradesPolicyLink } = {}
  } = myAcademics;
  return { academicGuideGradesPolicyLink };
};

export default connect(mapStateToProps)(SectionIncompleteGradingStatus);
