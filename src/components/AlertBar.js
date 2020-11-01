import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';

import styles from './AlertBar.module.scss';
import { propTypes as ServiceAlertProps } from './ServiceAlerts/serviceAlert.module.js';
import { fetchServiceAlerts } from 'actions/serviceAlertsActions';

function AlertBar({ fetchServiceAlerts, loadState, serviceAlerts }) {
  useEffect(() => {
    fetchServiceAlerts();
  }, []);

  if (loadState === 'success') {
    const { title, splash_only } = serviceAlerts[0];

    if (splash_only) {
      return null;
    }

    return (
      <div className={styles.AlertBar}>
        <div className={styles.content}>
          <strong className={styles.title}>CalCentral Update</strong>
          <div>
            <i className="fa fa-warning" /> {title}
          </div>
        </div>
        <div className={styles.linkContainer}>
          <Link to="/calcentral_update">
            <strong>Learn More</strong>
          </Link>
        </div>
      </div>
    );
  }

  return null;
}

AlertBar.propTypes = {
  fetchServiceAlerts: PropTypes.func,
  loadState: PropTypes.string,
  serviceAlerts: PropTypes.arrayOf(PropTypes.shape(ServiceAlertProps)),
};

const mapDispatchToProps = dispatch => ({
  fetchServiceAlerts: () => {
    dispatch(fetchServiceAlerts());
  },
});

const mapStateToProps = ({ serviceAlerts: { data, loadState } }) => ({
  serviceAlerts: data,
  loadState: loadState,
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(AlertBar);
