import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import store from 'Redux/store';
import { Provider, connect } from 'react-redux';
import { react2angular } from 'react2angular';
import {
  fetchAwardComparison,
  fetchAwardComparisonSnapshot,
} from 'Redux/actions/awardComparisonActions';
import Spinner from '../../Spinner';
import SelectedDateContext from './SelectedDateContext';
import Card from 'React/components/Card';
import Instructions from './Instructions';
import Dropdowns from './Dropdowns';
import Legend from './Legend';
import Summary from './Summary';
import Awards from './Awards';
import CostOfAttendance from './CostOfAttendance';
import Profile from './Profile';
import './AwardComparison.scss';

const propTypes = {
  dispatch: PropTypes.func.isRequired,
  currentUrl: PropTypes.string.isRequired,
  awardComparison: PropTypes.object.isRequired,
  awardComparisonSnapshot: PropTypes.object,
};

const Gap = () => {
  return <div className="gap" />;
};

const AwardComparison = ({
  dispatch,
  currentUrl,
  awardComparison,
  awardComparisonSnapshot,
}) => {
  useEffect(() => {
    dispatch(fetchAwardComparison());
  }, []);

  const [currentAidYear, setCurrentAidYear] = useState(
    currentUrl.match(/\d+$/)[0]
  );
  const [asOfCurrentDate, setAsOfCurrentDate] = useState(null);
  const [selectedDate, setSelectedDate] = useState('X');
  const [summaryExpanded, setSummaryExpanded] = useState(true);
  const [awardsExpanded, setAwardsExpanded] = useState(false);
  const [costExpanded, setCostExpanded] = useState(false);
  const [profileExpanded, setProfileExpanded] = useState(false);

  const { aidYears = [], loaded, errored, message } = awardComparison;

  useEffect(() => {
    if (aidYears.length > 0) {
      const activityDatesList = aidYears.find(ay => ay.id === currentAidYear)
        .activityDates;
      /* We will use the max activity date (element [0]) as the "Current" date on the card */
      setAsOfCurrentDate(activityDatesList[0]);
    }
  }, [aidYears, currentAidYear]);

  useEffect(() => {
    if (selectedDate !== 'X') {
      dispatch(fetchAwardComparisonSnapshot(currentAidYear, selectedDate));
    }
  }, [selectedDate]);

  const loading = !loaded;
  const error = errored
    ? {
        message:
          'There is a problem displaying your information. Please try again soon.',
      }
    : null;

  const onAidYearChange = newAidYear => {
    setCurrentAidYear(newAidYear);
    setSelectedDate('X');
    setAsOfCurrentDate(null);
  };

  const onDateChange = newSelectedDate => {
    setSelectedDate(newSelectedDate);
  };

  const onExpand = (action, value) => {
    action(!value);
  };

  const currentAidYearData = aidYears.find(ay => ay.id === currentAidYear);

  const {
    aidYears: {
      [currentAidYear]: { [selectedDate]: aidYearSnapshot = {} } = {},
    } = {},
  } = awardComparisonSnapshot;

  return (
    <Card
      className="AwardComparison"
      title="Award Comparison"
      loading={loading}
      error={error}
    >
      {!loading && !error && asOfCurrentDate && (
        <SelectedDateContext.Provider value={{ selectedDate: selectedDate }}>
          <div className="AwardComparison">
            <Instructions message={message} />
            <div className="container">
              <Dropdowns
                aidYear={currentAidYear}
                aidYears={aidYears}
                onAidYearChange={onAidYearChange}
                selectedDate={selectedDate}
                onDateChange={onDateChange}
              />
              <Legend
                asOfCurrentDate={asOfCurrentDate}
                selectedDate={selectedDate}
              />
              {selectedDate === 'X' ||
              (aidYearSnapshot && aidYearSnapshot.loaded) ? (
                <>
                  <Gap />
                  <Summary
                    expanded={summaryExpanded}
                    onExpand={onExpand}
                    setExpand={setSummaryExpanded}
                    aidYearData={currentAidYearData}
                    aidYearSnapshot={aidYearSnapshot}
                  />
                  <Gap />
                  <Awards
                    expanded={awardsExpanded}
                    onExpand={onExpand}
                    setExpand={setAwardsExpanded}
                    aidYearData={currentAidYearData}
                    aidYearSnapshot={aidYearSnapshot}
                  />
                  <Gap />
                  <CostOfAttendance
                    expanded={costExpanded}
                    onExpand={onExpand}
                    setExpand={setCostExpanded}
                    aidYearData={currentAidYearData}
                    aidYearSnapshot={aidYearSnapshot}
                  />
                  <Gap />
                  <Profile
                    expanded={profileExpanded}
                    onExpand={onExpand}
                    setExpand={setProfileExpanded}
                    aidYearData={currentAidYearData}
                    aidYearSnapshot={aidYearSnapshot}
                  />
                </>
              ) : (
                <Spinner />
              )}
            </div>
          </div>
        </SelectedDateContext.Provider>
      )}
    </Card>
  );
};

AwardComparison.displayName = 'AwardComparison';
AwardComparison.propTypes = propTypes;

const mapStateToProps = ({
  currentRoute: { url: currentUrl },
  awardComparison = {},
  awardComparisonSnapshot = {},
}) => {
  return {
    currentUrl,
    awardComparison,
    awardComparisonSnapshot,
  };
};

const ConnectedAwardComparison = connect(mapStateToProps)(AwardComparison);

const AwardComparisonContainer = () => {
  return (
    <Provider store={store}>
      <ConnectedAwardComparison />
    </Provider>
  );
};

angular
  .module('calcentral.react')
  .component('awardComparison', react2angular(AwardComparisonContainer));
