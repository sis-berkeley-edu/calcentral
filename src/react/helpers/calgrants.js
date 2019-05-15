const CAL_GRANT_STATE_COMPLETE = 'Complete';
const CAL_GRANT_STATE_INCOMPLETE = 'Incomplete';

export const CALGRANT_SERVICE_INDICATOR_TYPE_CODE = 'F06';

export const isComplete = (acknowledgement) => acknowledgement.status === CAL_GRANT_STATE_COMPLETE;
export const isIncomplete = (acknowledgement) => acknowledgement.status === CAL_GRANT_STATE_INCOMPLETE;


export const findCalGrantHoldForTermId = (termId) => {
  return (hold) => {
    return hold.typeCode === CALGRANT_SERVICE_INDICATOR_TYPE_CODE
      && hold.fromTerm.id === termId;
  };
};
