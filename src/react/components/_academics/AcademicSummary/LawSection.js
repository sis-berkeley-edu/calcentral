import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import ValueOrDash from './ValueOrDash';
import SectionIncompleteGradingStatus from './SectionIncompleteGradingStatus';

const LawSection = ({
  klass,
  sectionLabel,
  requirementsDesignation,
  lawUnits,
  grading,
  units,
  canViewGrades,
}) => {
  const formattedlawUnits = lawUnits || '0.0';
  return (
    <Fragment>
      <tr>
        <td>
          <a href={klass.url}>
            {klass.course_code}&nbsp;
            {sectionLabel && <Fragment>{sectionLabel}&nbsp;</Fragment>}
            {klass.session_code && (
              <Fragment>(Session {klass.session_code})</Fragment>
            )}
          </a>
        </td>
        <td>
          {klass.title}&nbsp;
          {requirementsDesignation && (
            <div className="cc-requirements-designation">
              {requirementsDesignation}
            </div>
          )}
        </td>
        <td className="cc-text-right cc-academic-summary-table-units">
          <ValueOrDash value={units} />
        </td>
        <td className="cc-text-right cc-academic-summary-table-units">
          <ValueOrDash value={formattedlawUnits} />
        </td>
        <td>
          {canViewGrades && grading && <ValueOrDash value={grading.grade} />}
        </td>
        <td></td>
      </tr>
      <SectionIncompleteGradingStatus
        gradingLapseDeadlineDisplay={grading.gradingLapseDeadlineDisplay}
        gradingLapseDeadline={grading.gradingLapseDeadline}
        gradingBasis={grading.gradingBasis}
      />
    </Fragment>
  );
};
LawSection.propTypes = {
  klass: PropTypes.object,
  canViewGrades: PropTypes.bool,
  showPoints: PropTypes.bool,
  requirementsDesignation: PropTypes.string,
  units: PropTypes.number,
  lawUnits: PropTypes.number,
  grading: PropTypes.object,
  sectionLabel: PropTypes.string,
};

export default LawSection;
