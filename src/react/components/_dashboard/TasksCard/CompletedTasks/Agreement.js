import React from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import APILink from 'react/components/APILink';
import Task from '../Task';
import TaskHeader from '../TaskHeader';
import TaskTitle from '../TaskTitle';
import CampusSolutionsIcon from '../Icons/CampusSolutionsIcon';

const LinkName = ({ updates }) => {
  return (
    <span>
      {updates ? 'View/Update' : 'View'} <i className="fa fa-arrow-right"></i>
    </span>
  );
};

LinkName.propTypes = {
  updates: PropTypes.bool,
};

const Agreement = ({ agreement: task, index }) => {
  return (
    <Task index={index} task={task} type="" hasDetail={false}>
      <TaskHeader task={task}>
        <CampusSolutionsIcon />
        <TaskTitle
          title={task.title}
          subtitle={`Responded ${task.response} on ${shortDateIfCurrentYear(
            parseDate(task.responseDate)
          )}`}
        />

        {task.url && (
          <APILink
            {...task.url}
            name={<LinkName updates={task.updatesAllowed} />}
          />
        )}
      </TaskHeader>
    </Task>
  );
};

Agreement.propTypes = {
  agreement: PropTypes.object,
  index: PropTypes.number,
};

export default Agreement;
