import React from 'react';
import PropTypes from 'prop-types';

import 'react/stylesheets/tables.scss';
import styles from './ClassInformationCard.module.scss';

const VerticalClassAttributes = ({
  role,
  units,
  gradingBasis,
  academicGuide,
  isLaw,
}) => (
  <table className={`table ${styles.table}`} style={{ width: `100%` }}>
    <tbody>
      {role && (
        <tr>
          <th>Role</th>
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
          <th>Units</th>
          <td>{gradingBasis}</td>
        </tr>
      )}

      {!isLaw && (
        <tr>
          <th>Academic Guide</th>
          <td>
            <a href={academicGuide}>View Class Notes</a>
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
