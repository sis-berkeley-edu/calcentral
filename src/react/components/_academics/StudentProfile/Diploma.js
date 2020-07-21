import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import ReduxProvider from 'React/components/ReduxProvider';

import DiplomaContent from '../Diploma/Diploma'

import { fetchAcademicsDiploma } from 'Redux/actions/academics/diplomaActions';

const propTypes = {
  dispatch: PropTypes.func.isRequired
};

const Diploma = ({ dispatch, diplomaEligible }) => {

  useEffect(() => {
    dispatch(fetchAcademicsDiploma());
  }, []);

  if (diplomaEligible) {
    return (
      <tr>
        <th>Diploma</th>
        <td>
          <table className="student-profile__subtable">
            <tbody>
              <tr>
                <td>
                  <DiplomaContent />
                </td>
              </tr>
            </tbody>
          </table>
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

Diploma.propTypes = propTypes;

const mapStateToProps = ({ academics: { diploma: { diplomaEligible} } }) => {
  return { diplomaEligible };
};

const ConnectedDiploma = connect(mapStateToProps)(
  Diploma
);

const DiplomaContainer = () => {
  return (
    <ReduxProvider>
      <ConnectedDiploma />
    </ReduxProvider>
  );
};

export default DiplomaContainer;
