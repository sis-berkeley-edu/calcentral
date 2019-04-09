import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import ValueOrDash from './ValueOrDash';

const propTypes = {
  class: PropTypes.object,
  requirementsDesignation: PropTypes.string,
  units: PropTypes.string,
  lawUnits: PropTypes.string,
  grading: PropTypes.object,
  isLaw: PropTypes.bool,
  showPoints: PropTypes.bool,
  canViewGrades: PropTypes.bool.isRequired,
  totalLawUnits: PropTypes.string
};

const PrimarySection = (props) => (
  <tr>
    <td>
      <a href={props.class.url}>
        {props.class.course_code}&nbsp;
        {props.class.session_code &&
          <Fragment>
            (Session {props.class.session_code})
          </Fragment>
        }
      </a>
    </td>
    <td>
      {props.class.title}&nbsp;
      {props.requirementsDesignation &&
        <div className="cc-requirements-designation">
          {props.requirementsDesignation}
        </div>
      }
    </td>
    <td className="cc-text-right cc-academic-summary-table-units">
      <ValueOrDash value={props.units} />
    </td>

    {props.lawUnits &&
      <td className="cc-text-right cc-academic-summary-table-units">
        <ValueOrDash value={props.lawUnits} />
      </td>
    }

    <td>
      {props.canViewGrades && props.grading &&
        <ValueOrDash value={props.grading.grade} />
      }
    </td>
    <td>
      {props.canViewGrades && props.showPoints && props.grading &&
        <ValueOrDash value={props.grading.gradePointsAdjusted} />
      }
    </td>
  </tr>
);

PrimarySection.propTypes = propTypes;

export default PrimarySection;
