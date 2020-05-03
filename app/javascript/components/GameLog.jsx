import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'

const GameLog = props => (
  <div className="game_info__log">
    { props.log.reverse().map( (item, index) => 
      <div key={index} className="game_info__log__item">
        <span className="game_info__log__item__player">{ `[${item['player']}]` }</span>
        <span className={`game_info__log__item__message--${index == 0 ? 'first' : item['type']}`}>{ item['message'] }</span>
      </div>
     ) }
  </div>
)

GameLog.defaultProps = {
  log: []
}

GameLog.propTypes = {
  log: PropTypes.array,
}

const mapStateToProps = (state) => {
  return { 
    log: state.game.log,
  }
}

export default connect(mapStateToProps)(GameLog)
