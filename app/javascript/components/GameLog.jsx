import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import Card from './Card'

const GameLog = props => (
  <div className="game_info__log--parent">
    <div className="game_info__log">
      { props.log.reverse().map( (item, index) => 
        <div key={index} className="game_info__log__item">
          <span className="game_info__log__item__player">{ `[${item['player']}]` }</span>
          <span className={`game_info__log__item__message--${index == 0 ? 'first' : item['type']}`}>{ item['message'] }</span>
        </div>
      ) }
    </div>
    { props.pendingAnswer && props.defendFrom && <div className="game_info__log__current_card">
      <span className="game_info__log__current_card__log">
        {props.lastAction}<br/>
        Esperando por: {props.pendingUsers.join(', ')}
      </span>
      <Card name={props.defendFrom.name} visible={true} />
    </div>}
  </div>
)

GameLog.defaultProps = {
  log: []
}

GameLog.propTypes = {
  log: PropTypes.array,
}

const mapStateToProps = (state) => {
  const { game } = state;
  return { 
    log: [...game.log],
    lastAction: game.last_action,
    defendFrom: game.defend_from,
    pendingAnswer: game.pending_answer && game.pending_answer.length > 0,
    pendingUsers: game.pending_answer && game.pending_answer.map( (p) => p.user.username ),
  }
}

export default connect(mapStateToProps)(GameLog)
