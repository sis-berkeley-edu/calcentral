import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import ValueOrDash from './ValueOrDash';

const propTypes = {
  section: PropTypes.object,
  canViewGrades: PropTypes.bool,
  showPoints: PropTypes.bool
};

const PrimarySection = ({ section, canViewGrades, showPoints }) => {
  const {
    class: klass,
    requirementsDesignation,
    units,
    lawUnits,
    grading
  } = section;

  return (
    <tr>
      <td>
        <a href={klass.url}>
          {klass.course_code}&nbsp;
          {klass.session_code &&
            <Fragment>
              (Session {klass.session_code})
            </Fragment>
          }
        </a>
      </td>
      <td>
        {klass.title}&nbsp;
        {requirementsDesignation &&
          <div className="cc-requirements-designation">
            {requirementsDesignation}
          </div>
        }
      </td>
      <td className="cc-text-right cc-academic-summary-table-units">
        <ValueOrDash value={units} />
      </td>
      {lawUnits &&
        <td className="cc-text-right cc-academic-summary-table-units">
          <ValueOrDash value={lawUnits} />
        </td>
      }
      <td>
        {canViewGrades && grading &&
          <ValueOrDash value={grading.grade} />
        }
      </td>
      <td>
        {canViewGrades && showPoints && grading &&
          <ValueOrDash value={grading.gradePointsAdjusted} />
        }
      </td>
    </tr>
  );
};

PrimarySection.propTypes = propTypes;

const mapStateToProps = ({ myStatus }) => {
  const { canViewGrades } = myStatus;
  return { canViewGrades };
};

export default connect(mapStateToProps)(PrimarySection);
