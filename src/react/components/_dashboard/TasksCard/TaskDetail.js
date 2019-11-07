import React from 'react';
import PropTypes from 'prop-types';

import styles from './TaskDetail.module.scss';
import APILink from 'react/components/APILink';

const TaskDetail = ({ task }) => {
  const { departmentName, description, actionUrl, hasUpload, uploadUrl } = task;

  const descriptionStyles = `cc-break-word cc-clearfix cc-text-pre-line ${styles.description}`;
  const actionStyles = `cc-button cc-widget-tasks-button cc-outbound-link ${styles.actionLink}`;

  return (
    <div className={styles.wrapper}>
      {departmentName && (
        <p>
          <strong>From {departmentName}</strong>
        </p>
      )}

      <div className={descriptionStyles}>{description}</div>

      {actionUrl && (
        <a
          className={actionStyles}
          href={actionUrl}
          onClick={e => e.stopPropagation()}
        >
          Respond
        </a>
      )}

      {hasUpload && (
        <APILink
          {...uploadUrl}
          name="Upload"
          className="cc-button"
          style={{ marginTop: `10px`, display: `inline-block` }}
        />
      )}
    </div>
  );
};

TaskDetail.propTypes = {
  task: PropTypes.shape({
    departmentName: PropTypes.string,
    description: PropTypes.string,
    actionUrl: PropTypes.string,
    hasUpload: PropTypes.bool,
    uploadUrl: PropTypes.object,
  }),
};

export default TaskDetail;
