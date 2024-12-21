// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GroupMentorship {
    address public owner;
    uint256 public sessionCount;

    struct Session {
        uint256 id;
        string topic;
        uint256 price;
        uint256 startTime;
        address mentor;
        address[] attendees;
    }

    mapping(uint256 => Session) public sessions;
    mapping(address => uint256[]) public userSessions;

    event SessionCreated(uint256 id, string topic, uint256 price, uint256 startTime, address mentor);
    event UserEnrolled(uint256 sessionId, address user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createSession(
        string memory _topic,
        uint256 _price,
        uint256 _startTime
    ) public {
        require(_startTime > block.timestamp, "Start time must be in the future");

        sessionCount++;
        Session storage newSession = sessions[sessionCount];
        newSession.id = sessionCount;
        newSession.topic = _topic;
        newSession.price = _price;
        newSession.startTime = _startTime;
        newSession.mentor = msg.sender;

        emit SessionCreated(sessionCount, _topic, _price, _startTime, msg.sender);
    }

    function enrollInSession(uint256 _sessionId) public payable {
        Session storage session = sessions[_sessionId];
        require(msg.value == session.price, "Incorrect payment amount");
        require(session.startTime > block.timestamp, "Session has already started");

        session.attendees.push(msg.sender);
        userSessions[msg.sender].push(_sessionId);

        emit UserEnrolled(_sessionId, msg.sender);
    }

    function getAttendees(uint256 _sessionId) public view returns (address[] memory) {
        return sessions[_sessionId].attendees;
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
