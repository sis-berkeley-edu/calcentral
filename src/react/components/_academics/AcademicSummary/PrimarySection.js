import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import ValueOrDash from './ValueOrDash';
import SectionIncompleteGradingStatus from './SectionIncompleteGradingStatus';
import LawSection from './LawSection';

const propTypes = {
  section: PropTypes.object,
  canViewGrades: PropTypes.bool,
  showPoints: PropTypes.bool
};


let SingleSection = ({
  showPoints,
  canViewGrades,
  klass,
  requirementsDesignation,
  units,
  lawUnits,
  grading,
  sectionLabel,
  isLawStudent
}) => {
  if (lawUnits > 0) {
    return (
      <LawSection
        klass={klass}
        requirementsDesignation={requirementsDesignation}
        sectionLabel={sectionLabel}
        lawUnits={lawUnits}
        grading={grading}
        units={units}
      />
    );
  }

  return (
    <Fragment>
      <tr>
        <td>
          <a href={klass.url}>
            {klass.course_code}&nbsp;
            {sectionLabel &&
              <Fragment>
                {sectionLabel}&nbsp;
              </Fragment>
            }
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
          {!isLawStudent && canViewGrades && showPoints && grading &&
            <ValueOrDash value={grading.gradePointsAdjusted} />
          }
        </td>
      </tr>
      <SectionIncompleteGradingStatus
        gradingLapseDeadlineDisplay={grading.gradingLapseDeadlineDisplay}
        gradingLapseDeadline={grading.gradingLapseDeadline}
        gradingBasis={grading.gradingBasis}/>
    </Fragment>
  );
};
SingleSection.propTypes = {
  klass: PropTypes.object,
  canViewGrades: PropTypes.bool,
  showPoints: PropTypes.bool,
  requirementsDesignation: PropTypes.string,
  units: PropTypes.string,
  lawUnits: PropTypes.string,
  grading: PropTypes.object,
  sectionLabel: PropTypes.string,
  isLawStudent: PropTypes.bool
};

const mapSectionStateToProps = ({
  myStatus: {
    roles: {
      law: isLawStudent
    } = {}
  } = {}
}) => ({ isLawStudent });

SingleSection = connect(mapSectionStateToProps)(SingleSection);

const PrimarySection = ({ section, canViewGrades, showPoints }) => {
  if (section.class.multiplePrimaries) {
    return section.class.sections.map((sek, index) => (
      <SingleSection
        key={index}
        showPoints={showPoints}
        canViewGrades={canViewGrades}
        klass={section.class}
        requirementsDesignation={section.requirementsDesignation}
        units={sek.units}
        lawUnits={sek.lawUnits}
        grading={sek.grading}
        sectionLabel={sek.section_label} />
    ));
  }
  return <SingleSection
    showPoints={showPoints}
    canViewGrades={canViewGrades}
    klass={section.class}
    requirementsDesignation={section.requirementsDesignation}
    units={section.units}
    lawUnits={section.lawUnits}
    grading={section.grading}
    sectionLabel={null} />;
};

PrimarySection.propTypes = propTypes;

const mapStateToProps = ({ myStatus }) => {
  const { canViewGrades } = myStatus;
  return { canViewGrades };
};

export default connect(mapStateToProps)(PrimarySection);
