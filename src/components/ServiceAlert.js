import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { fetchServiceAlerts } from 'actions/serviceAlertsActions';

import SplashContainer from './SplashContainer';
import SplashAlert from 'components/ServiceAlerts/SplashAlert';

function ServiceAlerts({ fetchServiceAlert, serviceAlerts, loadState }) {
  useEffect(() => {
    fetchServiceAlert();
  }, []);

  if (loadState === 'success') {
    return (
      <SplashContainer>
        <div className="cc-splash-page-note-title">CalCentral News</div>

        {serviceAlerts.map(alert => (
          <SplashAlert key={alert.id} serviceAlert={alert} />
        ))}
      </SplashContainer>
    );
  }

  return null;
}

ServiceAlerts.propTypes = {
  fetchServiceAlert: PropTypes.func,
  serviceAlerts: PropTypes.array,
  loadState: PropTypes.string,
};

const mapStateToProps = ({ serviceAlerts: { data = [], loadState } }) => ({
  serviceAlerts: data,
  loadState,
});

const mapDispatchToProps = dispatch => ({
  fetchServiceAlert() {
    dispatch(fetchServiceAlerts());
  },
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ServiceAlerts);
