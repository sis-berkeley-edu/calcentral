import React from 'react';
import PropTypes from 'prop-types';

import styles from './SourceAndTypeGroup.module.scss';

import DisclosureChevron from 'react/components/DisclosureChevron';
import Linkify from 'react-linkify';

import GradedLabel from './GradedLabel';

import Notification from './notification';

const SingleNotification = ({
  source,
  notification,
  expanded,
  setExpanded,
}) => {
  const isExpanded = notification.id === expanded;

  const expand = () => {
    isExpanded ? setExpanded('') : setExpanded(notification.id);
  };

  return (
    <div className={`${styles.singleNotificationGroup}`}>
      <div onClick={() => expand()} className={styles.expandHeader}>
        <div style={{ flex: `1` }}>
          <div className={styles.sourceLabel}>{source}</div>
          <div className={styles.secondaryLabel}>
            {notification.type === 'gradeposting' && <GradedLabel />}{' '}
            {notification.title}
          </div>
        </div>

        <div style={{ width: `20px`, textAlign: `right` }}>
          <DisclosureChevron expanded={isExpanded} />
        </div>
      </div>

      {isExpanded && (
        <div style={{ marginTop: `15px` }}>
          <Linkify>{notification.description}</Linkify>

          <p style={{ paddingTop: `15px`, marginBottom: `15px` }}>
            <a
              href={notification.url}
              onClick={e => e.stopPropagation()}
              target="_blank"
              rel="noopener noreferrer"
            >
              {Notification.linkText(notification)}
            </a>
          </p>
        </div>
      )}
    </div>
  );
};

SingleNotification.propTypes = {
  source: PropTypes.string,
  notification: PropTypes.shape({
    id: PropTypes.string,
    description: PropTypes.string,
    title: PropTypes.string,
    type: PropTypes.string,
    url: PropTypes.string,
  }),
  expanded: PropTypes.bool,
  setExpanded: PropTypes.func,
};

export default SingleNotification;
