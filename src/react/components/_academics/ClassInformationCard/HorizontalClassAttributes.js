import React from 'react';
import PropTypes from 'prop-types';

import 'react/stylesheets/tables.scss';
import styles from './ClassAttributesTable.module.scss';
import ClassNotesLink from './ClassNotesLink';

const HorizontalClassAttributes = ({
  role,
  units,
  gradingBasis,
  academicGuide,
  isLaw,
}) => (
  <table className={`table ${styles.classAttributesTable}`}>
    <thead>
      <tr>
        {role && <th>My Role</th>}
        {units && <th>Units</th>}
        {gradingBasis && <th>Grading</th>}
        {!isLaw && <th>Academic Guide</th>}
      </tr>
    </thead>
    <tbody>
      <tr>
        {role && <td>{role}</td>}
        {units && <td>{units}</td>}
        {gradingBasis && <td>{gradingBasis}</td>}
        {!isLaw && (
          <td>
            <ClassNotesLink href={academicGuide} />
          </td>
        )}
      </tr>
    </tbody>
  </table>
);

HorizontalClassAttributes.propTypes = {
  role: PropTypes.string,
  units: PropTypes.number,
  gradingBasis: PropTypes.string,
  semesterSlug: PropTypes.string,
  academicGuide: PropTypes.string,
  isLaw: PropTypes.bool,
};

export default HorizontalClassAttributes;
