import React from 'react';
import PropTypes from 'prop-types';

import 'react/stylesheets/tables.scss';
import styles from './ClassInformationCard.module.scss';

const HorizontalClassAttributes = ({
  role,
  units,
  gradingBasis,
  academicGuide,
  isLaw,
}) => (
  <table className={`table ${styles.table}`} style={{ width: `100%` }}>
    <thead>
      <tr>
        {role && <th>Role</th>}
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
            <a href={academicGuide}>View Class Notes</a>
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
