import { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { fetchStatus } from 'Redux/actions/statusActions';

const propTypes = {
  dispatch: PropTypes.func.isRequired,
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

const mapStateToProps = ({ myStatus = {} }) => ({
  isReady: myStatus.loaded,
  errored: myStatus.error,
});

export default connect(mapStateToProps)(WithAccess);
