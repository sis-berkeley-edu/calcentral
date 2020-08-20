import React from 'react';
import PropTypes from 'prop-types';

import 'react/stylesheets/tables.scss';
import styles from './ClassAttributesTable.module.scss';
import ClassNotesLink from './ClassNotesLink';

const VerticalClassAttributes = ({
  role,
  units,
  gradingBasis,
  academicGuide,
  isLaw,
}) => (
  <table className={`table ${styles.classAttributesTable}`}>
    <tbody>
      {role && (
        <tr>
          <th>My Role</th>
          <td>{role}</td>
        </tr>
      )}

      {units && (
        <tr>
          <th>Units</th>
          <td>{units}</td>
        </tr>
      )}

      {gradingBasis && (
        <tr>
          <th>Grading</th>
          <td>{gradingBasis}</td>
        </tr>
      )}

      {!isLaw && (
        <tr>
          <th>Academic Guide</th>
          <td>
            <ClassNotesLink href={academicGuide} />
          </td>
        </tr>
      )}
    </tbody>
  </table>
);

VerticalClassAttributes.propTypes = {
  role: PropTypes.string,
  units: PropTypes.string,
  gradingBasis: PropTypes.string,
  semesterSlug: PropTypes.string,
  academicGuide: PropTypes.string,
  isLaw: PropTypes.bool,
};

export default VerticalClassAttributes;
