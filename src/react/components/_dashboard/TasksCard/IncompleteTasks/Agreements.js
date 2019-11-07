import React, { Fragment, useState } from 'react';
import PropTypes from 'prop-types';

import APILink from 'react/components/APILink';
import Category from '../Category';
import CategoryHeader from './CategoryHeader';
import CategorySection from './CategorySection';
import Task from '../Task';
import TaskHeader from '../TaskHeader';
import TaskTitle from '../TaskTitle';
import CampusSolutionsIcon from '../Icons/CampusSolutionsIcon';

const ViewLink = () => {
  return (
    <Fragment>
      View <i className="fa fa-arrow-right"></i>
    </Fragment>
  );
};

const Agreements = ({ category, tasks }) => {
  const [expanded, setExpanded] = useState(false);

  return (
    <Category withBottomBorder={true}>
      <CategoryHeader
        title={category.title}
        expanded={expanded}
        setExpanded={setExpanded}
        incompleteCount={tasks.length}
      />

      {expanded && (
        <CategorySection items={tasks}>
          {tasks.map((task, index) => {
            return (
              <Task
                key={index}
                index={index}
                task={task}
                type=""
                hasDetail={false}
              >
                <TaskHeader task={task}>
                  <CampusSolutionsIcon />
                  <TaskTitle title={task.title} />

                  {task.url && <APILink {...task.url} name={<ViewLink />} />}
                </TaskHeader>
              </Task>
            );
          })}
        </CategorySection>
      )}
    </Category>
  );
};

Agreements.propTypes = {
  category: PropTypes.object,
  tasks: PropTypes.array,
};

export default Agreements;

// subtitle={`Due ${shortDateIfCurrentYear(
//   parseDate(task.dueDate)
// )}`}

/*
<Task key={index} index={index} task={task} type="">

    <CampusSolutionsIcon />
    <TaskTitle title={task.title} />
  </TaskHeader>
</Task>
*/
