import thunkMiddleware from 'redux-thunk'
import { createLogger } from 'redux-logger'
import { createStore, applyMiddleware } from "redux";
import gameReducer from "../reducers/game";

const loggerMiddleware = createLogger()
const store = createStore(
  gameReducer,
  applyMiddleware(
    thunkMiddleware, // lets us dispatch() functions
    loggerMiddleware // neat middleware that logs actions
  )
)

export default store;


