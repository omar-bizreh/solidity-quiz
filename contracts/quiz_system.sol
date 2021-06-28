// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;

import "./question.sol";

contract QuizContract {
    address student;
    address owner;
    bool closed;
    uint16 questionsCount;
    uint256 award;
    mapping(uint16 => Question) questions;
    mapping(uint16 => uint16) studentAnswers;
    uint16 score;

    constructor(address _student) {
        student = _student;
        owner = msg.sender;
    }

    // Allow only student of this quiz to make changes
    modifier studentOnly() {
        require(
            msg.sender == student,
            "Only student of this quiz can perform this action"
        );

        _;
    }

    // Allow only owner of this quiz to make changes
    modifier ownerOnly() {
        require(
            msg.sender == owner,
            "Only owner of this contract can perform this action"
        );

        _;
    }

    // Prevent changes if quiz is marked as closed
    modifier notClosed() {
        require(closed == false, "Quiz closed. Changes no longer accepted");

        _;
    }

    // Prevent changes if quiz is marked as closed
    modifier ifClosed() {
        require(
            closed == true,
            "Quiz not closed. You need to close this quiz before performing this acction"
        );

        _;
    }

    // Add new question to quiz
    // @params
    //      - id ID of quiz
    //      - question Byte representation of question string
    //      - _answers Possible answers for this question
    //      - correctAnswerIndex index of the correct answer in _answers list
    function addQuestion(
        uint16 id,
        bytes32 question,
        bytes32[] calldata _answers,
        uint16 correctAnswerIndex
    ) public ownerOnly {
        questionsCount++;
        questions[id].text = question;
        questions[id].id = id;
        questions[id].answers = _answers;
        questions[id].correctAnswerIndex = correctAnswerIndex;
    }

    // Gets question by index
    function getQuestion(uint16 index)
        public
        view
        returns (bytes32, bytes32[] memory)
    {
        return (questions[index].text, questions[index].answers);
    }

    // Removes an aswer list for question
    // @params:
    //      - questionId ID of question to modify
    //      - answerIndex Index of answer to remove
    function removeAnswer(uint16 questionId, uint16 answerIndex)
        public
        notClosed
        ownerOnly
    {
        questions[questionId].answers[answerIndex] = 0x0;
    }

    // Submit answer to question
    // @param
    //      - questionId ID of question being answered
    //      - answerIndex index of answer chosen
    function submitAnswer(uint16 questionId, uint16 answerIndex)
        public
        notClosed
        studentOnly
    {
        studentAnswers[questionId] = answerIndex;
    }

    // Calculates score for this quiz
    // Calculating score marks the quiz as closed
    // and will no longer accept changes
    function calculateScore() public notClosed ownerOnly {
        closeQuiz();
        for (uint16 index = 0; index < questionsCount; index++) {
            if (questions[index].correctAnswerIndex == studentAnswers[index]) {
                score++;
            }
        }
    }

    // Gets student score
    function getScore() public view ownerOnly ifClosed returns (uint16) {
        return score;
    }

    // Reward student ether if full score
    function rewardStudent() public payable ownerOnly ifClosed {
        require(score == questionsCount, "Student did not earn full score");
        payable(student).transfer(msg.value);
    }

    // Mark quiz as closed
    function closeQuiz() private {
        closed = true;
    }
}
