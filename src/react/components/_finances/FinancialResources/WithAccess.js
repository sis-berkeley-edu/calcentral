import { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { fetchProfile } from 'Redux/actions/profileActions';
import { fetchAcademics } from 'Redux/actions/academicsActions';

const propTypes = {
  dispatch: PropTypes.func.isRequired,
  myAcademics: PropTypes.object,
  myStatus: PropTypes.object,
};

const WithAccess = ({ dispatch, isReady, onReady, children }) => {
  useEffect(() => {
    dispatch(fetchProfile());
    dispatch(fetchAcademics());
  }, []);

  if (isReady) {
    onReady();
  }
  return children;
};

WithAccess.propTypes = propTypes;

const mapStateToProps = ({ myStatus = {}, myAcademics = {} }) => ({
  isReady: myStatus.loaded && myAcademics.loaded,
});

export default connect(mapStateToProps)(WithAccess);
