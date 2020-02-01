import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import styles from './Switcher.module.scss';

const TAB_INCOMPLETE = 'incomplete';
const TAB_COMPLETE = 'complete';

const Switcher = ({ incompleteCount, completeCount, tab, setTab }) => {
  const classNameForButton = buttonName => {
    return buttonName == tab ? 'cc-button cc-button-selected' : 'cc-button';
  };

  return (
    <div className={`medium-10 ${styles.buttonContainer}`}>
      <ul className="cc-button-group cc-even-2" role="tablist">
        <li>
          <button
            onClick={() => setTab(TAB_INCOMPLETE)}
            className={classNameForButton(TAB_INCOMPLETE)}
            role="tab"
          >
            Incomplete ({incompleteCount})
          </button>
        </li>
        <li>
          <button
            onClick={() => setTab(TAB_COMPLETE)}
            className={classNameForButton(TAB_COMPLETE)}
            role="tab"
          >
            Completed ({completeCount})
          </button>
        </li>
      </ul>
    </div>
  );
};

Switcher.propTypes = {
  incompleteCount: PropTypes.number,
  completeCount: PropTypes.number,
  tab: PropTypes.string,
  setTab: PropTypes.func,
};

const mapStateToProps = ({
  myAgreements: { incompleteAgreements = [], completedAgreements = [] },
  myChecklistItems: { completedItems = [], incompleteItems = [] },
  myBCoursesTodos: { bCoursesTodos = [] },
}) => {
  const incompleteCount =
    incompleteAgreements.length + incompleteItems.length + bCoursesTodos.length;
  const completeCount = completedAgreements.length + completedItems.length;

  return {
    incompleteCount,
    completeCount,
  };
};

export { Switcher, TAB_INCOMPLETE, TAB_COMPLETE };

export default connect(mapStateToProps)(Switcher);
