const CAL_GRANT_STATE_COMPLETE = 'Complete';
const CAL_GRANT_STATE_INCOMPLETE = 'Incomplete';

export const isComplete = (acknowledgement) => acknowledgement.status === CAL_GRANT_STATE_COMPLETE;
export const isIncomplete = (acknowledgement) => acknowledgement.status === CAL_GRANT_STATE_INCOMPLETE;
