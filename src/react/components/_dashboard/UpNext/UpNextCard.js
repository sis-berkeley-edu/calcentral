import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import NoBconnected from '../bConnected/NoBconnected';
import UpNextItem from './UpNextItem';
import Card from 'React/components/Card';
import { connect } from 'react-redux';
import { fetchMyUpNext } from 'Redux/actions/myUpNextActions';
import { fetchStatus } from 'Redux/actions/statusActions';
import './UpNextCard.scss';

const propTypes = {
  dispatch: PropTypes.func,
  date: PropTypes.object,
  items: PropTypes.arrayOf(PropTypes.object),
  isLoading: PropTypes.bool,
  error: PropTypes.object,
  hasGoogleAccessToken: PropTypes.bool,
  officialBmailAddress: PropTypes.string,
};

export const UpNextCard = ({
  dispatch,
  date,
  items,
  isLoading,
  error,
  hasGoogleAccessToken,
  officialBmailAddress,
}) => {
  useEffect(() => {
    dispatch(fetchMyUpNext());
    dispatch(fetchStatus());
  }, []);

  const [expandedItemIndex, setExpandedItemIndex] = useState(null);

  const hasItems = !!items.length;

  if (!officialBmailAddress) {
    return null;
  } else {
    return (
      <Card
        className="UpNextCard cc-react-widget"
        title="Up Next"
        loading={isLoading}
        error={error}
      >
        {hasItems && (
          <ul className="list">
            {items &&
              items.map((item, index) => (
                <UpNextItem
                  date={date}
                  item={item}
                  index={index}
                  key={index}
                  expandedItemIndex={expandedItemIndex}
                  setExpandedItemIndex={setExpandedItemIndex}
                />
              ))}
          </ul>
        )}
        {!hasItems && hasGoogleAccessToken && (
          <div className="top-spacing">
            You have no events scheduled for the rest of the day.
          </div>
        )}
        {!hasItems && !hasGoogleAccessToken && officialBmailAddress && (
          <div className="top-spacing">
            <NoBconnected mode="upnext" />
          </div>
        )}
        {!hasItems && !hasGoogleAccessToken && !officialBmailAddress && (
          <div className="top-spacing">
            Our records indicate that you do not currently have a bConnected
            account (UC Berkeley email and calendar). Visit{' '}
            <a
              target="_blank"
              rel="noopener noreferrer"
              href="https://mybconnected.berkeley.edu/manage/account/create_account"
            >
              bConnected
            </a>{' '}
            to create your bConnected account.
          </div>
        )}
      </Card>
    );
  }
};

const mapStateToProps = ({ myUpNext, myStatus }) => {
  const { date = null, items = [], isLoading, error = null } = myUpNext;

  const {
    hasGoogleAccessToken = false,
    officialBmailAddress = null,
  } = myStatus;

  return {
    date,
    items,
    isLoading,
    error,
    hasGoogleAccessToken,
    officialBmailAddress,
  };
};

UpNextCard.propTypes = propTypes;

export default connect(mapStateToProps)(UpNextCard);
