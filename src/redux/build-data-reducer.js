const buildDataReducer = (CONST_START, CONST_SUCCESS, CONST_FAILURE) => {
  return (state = {}, action) => {
    switch (action.type) {
      case CONST_START:
        return { ...state, isLoading: true, error: null };
      case CONST_SUCCESS:
        return {
          ...state,
          ...action.value,
          loaded: true,
          isLoading: false,
          error: null,
        };
      case CONST_FAILURE:
        return { ...state, isLoading: false, error: action.value };
      default:
        return state;
    }
  };
};

export default buildDataReducer;
