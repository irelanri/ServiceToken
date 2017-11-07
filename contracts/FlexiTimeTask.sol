pragma solidity ^0.4.4;

import "./FlexiTimeToken.sol";

/* Tracks under escrow token usage per specific task */
contract FlexiTimeTask {

  enum States { Created, Settled, Refunded }

  event StateChange(States indexed oldState, States indexed newState);

  string public name;
  States public state;
  FlexiTimeToken public token;

  modifier onlyCreated {
    require(state == States.Created);
    _;
  }

  function FlexiTimeTask(string _name) {
    name = _name;
    token = FlexiTimeToken(msg.sender);
    state = States.Created;
  }

  /* Beneficiary is able to settle with issuer by transferring tokens out of escrow */
  function settle() onlyCreated {
    require(msg.sender == token.agreement().beneficiary());
    token.transfer(token.agreement().issuer(), token.balanceOf(this));
    state = States.Settled;
    StateChange(States.Created, States.Settled);
  }

  /* Issuer is able to refund tokens in escrow back to beneficiary */
  function refund() onlyCreated {
    require(msg.sender == token.agreement().issuer());
    token.transfer(token.agreement().beneficiary(), token.balanceOf(this));
    state = States.Refunded;
    StateChange(States.Created, States.Refunded);
  }
}
