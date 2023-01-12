
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;


interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

interface IBEP20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20Metadata is IBEP20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) { return msg.sender; }
  function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

contract Ownable is Context {
  address public _owner;
  address immutable _creator;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    _transferOwnership(_msgSender());
    _creator = _msgSender();
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}




contract Mashida is 
  Context
  , Ownable
  , IBEP20
  , IBEP20Metadata
  
{
  
  string constant private _name = "Mashida";
  string constant private _symbol = "MSHD";
  uint8 constant private _decimals = 9;
  uint256 private _totalSupply;
  IPinkAntiBot public pinkAntiBot;
  bool public antiBotEnabled;

  address constant DEAD = 0x000000000000000000000000000000000000dEaD;

  //split TGE Token 
  address constant PRESALE = 0xA00580a81DC06b8BE0AeBc8E4a59bEa239FA07Ad; 
  address constant LIQUIDITY_PROVISION = 0x70aD465E081deB27294a82F4E83391De33A50876; 
  address constant ECOSYSTEM = 0x630C892889F12e99CFF9a3626859FC3f616577d1; 
  address constant TEAM = 0x6e51E6836cB4284242DdfA6068B654ed19718207; 
  address constant MARKETING = 0x7b7B98fB1B972688cA51b3E6EBe5C751839864c0; 
  address constant PRODUCT_DEVELOPMENT = 0x393679848c147dAd2179E63275d27056ae2f6647; 
  address constant TREASURY = 0x6D4e6982FBC64dA1D65D6462fc9cf468fBe330C0; 
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

 
  constructor() {
    emit OwnershipTransferred(address(0), _msgSender());
    //split TGE 
    _mint(PRESALE, 100000000 * 10 ** uint256(_decimals)); //1%
    _mint(LIQUIDITY_PROVISION, 3200000000 * 10 ** uint256(_decimals)); //32%
    _mint(ECOSYSTEM, 2000000000 * 10 ** uint256(_decimals)); //20%
    _mint(TEAM, 1000000000 * 10 ** uint256(_decimals)); //10%
    _mint(MARKETING, 1500000000 * 10 ** uint256(_decimals)); //15%
    _mint(PRODUCT_DEVELOPMENT, 1500000000 * 10 ** uint256(_decimals)); //15%
    _mint(TREASURY, 700000000 * 10 ** uint256(_decimals)); //7%
    address pinkAntiBot_;
    pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
    pinkAntiBot.setTokenOwner(msg.sender);
    antiBotEnabled = true;
  }

  receive() external payable {  }

  function name() public view virtual override returns (string memory) { return _name; }
  function symbol() public view virtual override returns (string memory) { return _symbol; }
  function decimals() public view virtual override returns (uint8) { return _decimals; }
  function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }
  function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }
  function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender]; }
  function currentBalance() public view returns(uint256) { return balanceOf(address(this)); }
  function contractBalance() public view returns(uint256) { return address(this).balance; }
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function setEnableAntiBot(bool _enable) external onlyOwner {
    antiBotEnabled = _enable;
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    if(_allowances[sender][_msgSender()] != ~uint(0)){
      _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()]-(amount);
    }

    _transfer(sender, recipient, amount);

    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, "MSHD: decreased allowance below zero");
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
    
    
  ) internal virtual returns(bool) {
    require(sender != address(0), "MSHD: transfer from the zero address");
    require(recipient != address(0), "MSHD: transfer to the zero address");
    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "MSHD: transfer amount exceeds balance");
    if (antiBotEnabled) {
    pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
    }
       _balances[sender] = senderBalance - amount;

    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }


  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "MSHD: mint to the zero address");

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }


  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "MSHD: approve from the zero address");
    require(spender != address(0), "MSHD: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}
