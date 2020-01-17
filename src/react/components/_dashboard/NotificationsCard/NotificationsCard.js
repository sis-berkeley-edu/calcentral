import React, { Fragment, useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import Card from 'react/components/Card';
import Spinner from 'react/components/Spinner';
import APILink from 'react/components/APILink';

import WebMessageGroup from './WebMessageGroup';
import SourceFilter from './SourceFilter';

const ArchiveLink = ({ url }) => {
  const link = {
    url: url,
    name: 'Archive of Official Communications',
  };

  return (
    <div
      className="cc-text-center cc-widget-padding"
      style={{ marginBottom: `-15px` }}
    >
      <APILink {...link} />
    </div>
  );
};

ArchiveLink.propTypes = {
  url: PropTypes.string,
};

const NotificationsCard = ({
  archiveUrl,
  canSeeCSLinks,
  fetchNotifications,
  notifications,
  loaded,
}) => {
  useEffect(() => {
    fetchNotifications();
  }, []);

  const [selectedSource, setSelectedSource] = useState('');
  const [expandedItem, setExpandedItem] = useState('');

  const messageSources = Object.keys(notifications).sort();
  const filteredSources = messageSources.filter(source =>
    selectedSource === '' ? source : source === selectedSource
  );

  return (
    <Card
      title="Notifications"
      secondaryContent={
        <SourceFilter
          sources={messageSources}
          setSelectedSource={setSelectedSource}
        />
      }
    >
      {loaded ? (
        <Fragment>
          {filteredSources.map(source => {
            return (
              <WebMessageGroup
                key={source}
                source={source}
                messages={notifications[source]}
                expandedItem={expandedItem}
                setExpandedItem={setExpandedItem}
              />
            );
          })}

          {canSeeCSLinks && <ArchiveLink url={archiveUrl} />}
        </Fragment>
      ) : (
        <Spinner />
      )}
    </Card>
  );
};

NotificationsCard.propTypes = {
  archiveUrl: PropTypes.string,
  canSeeCSLinks: PropTypes.bool,
  fetchNotifications: PropTypes.func,
  notifications: PropTypes.object,
  loaded: PropTypes.bool,
};

NotificationsCard.displayName = 'NotificationsCard';

export default NotificationsCard;
