import React from 'react'
import { connect } from 'react-redux'
import { render } from 'react-dom'
import { Provider } from 'react-redux'
import {combineReducers} from 'redux'
import Game from './Game'
import GameExtension from './GameExtension'
import {loadGame, loadGameSuccess, setCurrentUser} from '../actions/game'
import store from '../store/index'
import consumer from '../channels/consumer'

class App extends React.Component {

  constructor(props) {
    super(props);
    store.dispatch(loadGameSuccess(this.props.game));
    store.dispatch(setCurrentUser(this.props.current_user));
  }

  componentDidMount() {
    consumer.subscriptions.create({ channel: "GameChannel", game: this.props.game.id }, {
      received(data) { store.dispatch(loadGameSuccess(data)) }
    })

    setInterval(() => store.dispatch(loadGame(this.props.game.id)), 10000)
  }

  render() {
    return (
      <Provider store={store}>
      { !this.props.game.extension && <Game store={store} />}
      { this.props.game.extension && <GameExtension store={store} />}
      </Provider>
    );
  }
};

export default App
