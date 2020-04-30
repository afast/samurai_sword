import React from 'react'
import { connect } from 'react-redux'
import { render } from 'react-dom'
import { Provider } from 'react-redux'
import {combineReducers} from 'redux'
import Game from './Game'
import {loadGameSuccess} from '../actions/game'
import {setCurrentUser} from '../actions/game'
import store from '../store/index'

class App extends React.Component {

  constructor(props) {
    super(props);
    store.dispatch(loadGameSuccess(this.props.game));
    store.dispatch(setCurrentUser(this.props.current_user));
  }

  render() {
    return (
      <Provider store={store}>
        <Game store={store} />
      </Provider>
    );
  }
};

export default App
