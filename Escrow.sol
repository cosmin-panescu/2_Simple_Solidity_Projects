// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Escrow {
    // VARIABLES
    enum State {
        NOT_INITIATED,
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        COMPLETE
    }
    State public currentState;

    bool public isBuyerIn;
    bool public isSellerIn;

    uint256 public price;

    address public buyer;
    address payable public seller;

    // MODIFIERS
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function!");
        _;
    }

    modifier escrowNotStarted() {
        require(currentState == State.NOT_INITIATED);
        _;
    }

    // FUNCTIONS
    constructor(
        address _buyer,
        address payable _seller,
        uint256 _price
    ) {
        buyer = _buyer;
        seller = _seller;
        price = _price * (1 ether);
    }

    function initContract() public escrowNotStarted {
        if (msg.sender == buyer) {
            isBuyerIn = true;
        }
        if (msg.sender == seller) {
            isSellerIn = true;
        }
        if (isBuyerIn && isSellerIn) {
            currentState = State.AWAITING_PAYMENT;
        }
    }

    function deposit() public payable onlyBuyer {
        require(currentState == State.AWAITING_PAYMENT, "Already paid");
        require(msg.value == price, "Wrong deposit amount");
        currentState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery() public payable onlyBuyer {
        require(
            currentState == State.AWAITING_DELIVERY,
            "Cannot confirm delivery"
        );
        seller.transfer(price);
        currentState = State.COMPLETE;
    }

    function withdraw() public payable onlyBuyer {
        require(
            currentState == State.AWAITING_DELIVERY,
            "Cannot withdraw at this stage"
        );
        payable(msg.sender).transfer(price);
        currentState = State.COMPLETE;
    }
}
