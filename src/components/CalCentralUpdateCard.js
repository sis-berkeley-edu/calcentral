import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { format, parseISO } from 'date-fns';

import Card from 'react/components/Card';
import { fetchServiceAlerts } from 'actions/serviceAlertsActions';

// The "Update Card" is the destination of the "Learn More" link in the AlertBar
function CalCentralUpdateCard({ fetchServiceAlert, serviceAlert, loadState }) {
  useEffect(() => {
    fetchServiceAlert();
  });

  return (
    <Card title="CalCentral Update" loading={loadState === 'pending'}>
      {serviceAlert ? (
        <>
          <h3 style={{ marginTop: `15px` }}>
            {format(parseISO(serviceAlert.publication_date), 'MMM dd')} -{' '}
            {serviceAlert.title}
          </h3>
          <div dangerouslySetInnerHTML={{ __html: serviceAlert.body }}></div>
        </>
      ) : (
        <div>
          <p>There are no updates at this time.</p>
        </div>
      )}
    </Card>
  );
}

CalCentralUpdateCard.propTypes = {
  fetchServiceAlert: PropTypes.func,
  serviceAlert: PropTypes.shape({
    title: PropTypes.string,
    body: PropTypes.string,
    publication_date: PropTypes.string,
  }),
  loadState: PropTypes.string,
};

const mapDispatchToProps = dispatch => ({
  fetchServiceAlert: () => {
    dispatch(fetchServiceAlerts());
  },
});

const mapStateToProps = ({ serviceAlerts: { data = [], loadState } }) => ({
  serviceAlert: data[0],
  loadState,
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(CalCentralUpdateCard);
