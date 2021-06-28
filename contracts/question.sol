// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;
import "./answer.sol";

struct Question {
    uint16 id;
    bytes32 text;
    uint16 answerCount;
    bytes32[] answers;
    uint16 correctAnswerIndex;
}
