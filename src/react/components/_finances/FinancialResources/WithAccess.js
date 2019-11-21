import { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { fetchStatus } from 'Redux/actions/statusActions';
import { fetchAcademics } from 'Redux/actions/academicsActions';

const propTypes = {
  dispatch: PropTypes.func.isRequired,
  myAcademics: PropTypes.object,
  myStatus: PropTypes.object,
  children: PropTypes.node,
};

const WithAccess = ({
  dispatch,
  isReady,
  errored,
  onReady,
  onError,
  children,
}) => {
  useEffect(() => {
    dispatch(fetchStatus());
    dispatch(fetchAcademics());
  }, []);

  if (errored) {
    onError();
  }

  if (isReady) {
    onReady();
  }
  return children;
};

WithAccess.propTypes = propTypes;

const mapStateToProps = ({ myStatus = {}, myAcademics = {} }) => ({
  isReady: myStatus.loaded && myAcademics.loaded,
  errored: myStatus.error || myAcademics.error,
});

export default connect(mapStateToProps)(WithAccess);
