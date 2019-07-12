import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import CampusSolutionsLinkContainer from '../../CampusSolutionsLink/CampusSolutionsLinkContainer';

import './SectionIncompleteGradingStatus.scss';

const propTypes = {
  gradingLapseDeadlineDisplay: PropTypes.bool.isRequired,
  gradingLapseDeadline: PropTypes.string,
  academicGuideGradesPolicyLink: PropTypes.object.isRequired,
  gradingBasis: PropTypes.string.isRequired
};

const SectionIncompleteGradingStatus = ({
  gradingLapseDeadlineDisplay,
  gradingLapseDeadline,
  gradingBasis,
  academicGuideGradesPolicyLink}) => {
  return (
    <tr>
      <td colSpan={3}>&nbsp;</td>
      <td className="SectionIncompleteGradingStatus__table_cell">
        {gradingLapseDeadlineDisplay && gradingLapseDeadline &&
          <CampusSolutionsLinkContainer linkObj={academicGuideGradesPolicyLink}>Lapse Date</CampusSolutionsLinkContainer>
        }
        {gradingLapseDeadlineDisplay && gradingLapseDeadline &&
          ': ' + gradingLapseDeadline
        }
        {gradingBasis === 'FRZ' &&
          <CampusSolutionsLinkContainer linkObj={academicGuideGradesPolicyLink}>Frozen</CampusSolutionsLinkContainer>
        }
      </td>
      <td>&nbsp;</td>
    </tr>
  );
};

SectionIncompleteGradingStatus.propTypes = propTypes;

const mapStateToProps = ({ myAcademics }) => {
  const {
    studentLinks: { academicGuideGradesPolicy: academicGuideGradesPolicyLink }
  } = myAcademics;
  return { academicGuideGradesPolicyLink };
};

export default connect(mapStateToProps)(SectionIncompleteGradingStatus);
