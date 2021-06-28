const { expect } = require('chai');
const Web3 = require('web3');
const truffleAssert = require('truffle-assertions');
const toHex = (input) => Web3.utils.asciiToHex(input).padEnd(66, '0');
const toAscii = (input) => Web3.utils.toUtf8(input);
const studentAddress = '0x9D9deb5678dcA9eA44Ad36789B2661af5bF641D0';
let studentSigner;
const ownerAddress = '0xb474bC5da11653A0d795ECef65032f851f668bda';
let ownerSigner;

// Start test block
describe('Quiz', function () {
  before(async function () {
    studentSigner = await ethers.getSigner(studentAddress);
    ownerSigner = await ethers.getSigner(ownerAddress);
    this.QuizSystem = await ethers.getContractFactory(
      'QuizContract',
      ownerSigner
    );
    this.quiz = await this.QuizSystem.deploy(studentAddress);
    await this.quiz.deployed();
  });

  // Test case
  it('adds a question', async function () {
    // Add Question
    const AddQuestion = await this.quiz.addQuestion(
      0,
      toHex('How old are you?'),
      [toHex('10'), toHex('20'), toHex('30')],
      2
    );

    await AddQuestion.wait();
    const questionInfo = await this.quiz.getQuestion(0);
    const questionString = toAscii(questionInfo[0]);

    expect(questionString).to.equal('How old are you?');
  });

  it('adds answer to question', async function () {
    const existing = this.quiz.connect(studentSigner);
    const AddAnswer = await existing.submitAnswer(0, 2);

    await AddAnswer.wait();
  });

  it('should fail to get score of un-closed quiz', async function () {
    await truffleAssert.reverts(this.quiz.getScore());
  });

  it('calculates score', async function () {
    const CalculateScore = await this.quiz.calculateScore();
    await CalculateScore.wait();
  });

  it('shows correct score', async function () {
    const score = await this.quiz.getScore();
    expect(`${score}`).to.equal('1');
  });

  it('should fail to answer closed quiz', async function () {
    const existing = this.quiz.connect(studentSigner);
    await truffleAssert.reverts(existing.submitAnswer(0, 2));
  });

  it('reward student if all answers correct', async function () {
    const Reward = await this.quiz.rewardStudent({
      value: Web3.utils.toWei('1'),
    });
    await Reward.wait();
  });
});
