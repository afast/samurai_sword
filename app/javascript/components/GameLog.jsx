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
    { props.defendFrom && (props.defendFrom.name == 'intuicion' || props.pendingAnswer) && <div className="game_info__log__current_card">
      <span className="game_info__log__current_card__log">
        {props.lastAction}<br/>
        Esperando por: {props.pendingUsers.join(', ')}
      </span>
      <Card name={props.defendFrom.name} visible={true} />
      { props.defendFrom.name == 'intuicion' && props.proposed && <div className='game_info__log__intuicion_card'><Card name={props.proposed} visible={true} /></div> }
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
  let currentPlayer;
  game.players.map( (p) => { if (p.user.id == state.currentUser.id) currentPlayer = p } )

  return { 
    log: [...game.log],
    lastAction: game.last_action,
    defendFrom: game.defend_from,
    proposed: game.intuicion_list && game.intuicion_list[currentPlayer.character],
    pendingAnswer: game.pending_answer && game.pending_answer.length > 0,
    pendingUsers: game.pending_answer && game.pending_answer.map( (p) => p.user.username ),
  }
}

export default connect(mapStateToProps)(GameLog)
