import {
  FETCH_AWARD_COMPARISON_SNAPSHOT_START,
  FETCH_AWARD_COMPARISON_SNAPSHOT_SUCCESS,
  FETCH_AWARD_COMPARISON_SNAPSHOT_FAILURE,
} from '../actions/awardComparisonActions';

const appendEffectiveDateToAidYear = (state, action, values) => {
  // Replace Aid existing data and add the new effective date loading state
  const aidYear = {
    ...((state.aidYears && state.aidYears[action.aidYear]) || null),
    [action.effectiveDate]: {
      ...((state.aidYears[action.aidYear] &&
        state.aidYears[action.aidYear][action.effectiveDate]) ||
        null),
      ...values,
    },
  };

  const aidYears = { ...state.aidYears, [action.aidYear]: aidYear };

  return { ...state, aidYears };
};

const AwardComparisonSnapshotReducer = (state = { aidYears: {} }, action) => {
  const aidYears = { ...aidYears };
  switch (action.type) {
    case FETCH_AWARD_COMPARISON_SNAPSHOT_START:
      return appendEffectiveDateToAidYear(state, action, { loaded: false });
    case FETCH_AWARD_COMPARISON_SNAPSHOT_SUCCESS:
      return appendEffectiveDateToAidYear(state, action, {
        ...action.value,
        loaded: true,
        errored: false,
      });
    case FETCH_AWARD_COMPARISON_SNAPSHOT_FAILURE:
      return appendEffectiveDateToAidYear(state, action, {
        loaded: true,
        errored: true,
        error: action.value,
      });
    default:
      return state;
  }
};

export default AwardComparisonSnapshotReducer;
