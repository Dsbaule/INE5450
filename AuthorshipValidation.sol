pragma solidity >=0.5.11 <0.6.0;

contract Publication {
    Author public author;
    string public kind;
    string public hash;
  
  	constructor(Author _author, string memory _kind, string memory _hash) public {
		author = _author;
      	kind = _kind;
      	hash = _hash;
    }
}

contract Author {
    mapping(string => Publication) public publications;
    mapping(string => bool) public published;
    
    Publisher public publisher;
    address public owner;
    string public name;
  
  	constructor(Publisher pub, string memory _name) public {
		publisher = pub;
		name = _name;
		owner = msg.sender;
    }
    
    modifier is_owner {
        require(owner ==  msg.sender);
        _;
    }
    
    function publish (string memory _kind, string memory _hash) is_owner public {
        publications[_hash] = new Publication(this, _kind, _hash);
        published[_hash] = true;
    }
    
    function check_if_published(string memory _hash) public view returns(bool) {
        return published[_hash];
    }
}

contract Publisher {
    mapping(address => bool) public admins;
    mapping(address => Author) public authors;
    mapping(address => bool) public signed_up;
    mapping(string => bool) public published;
    
    address private owner;
    string public name;
    
  	constructor(string memory _name) public {
  	    name = _name;
		owner = msg.sender;
		admins[msg.sender] = true;
    }
    
    modifier is_owner {
        require(owner ==  msg.sender);
        _;
    }

    modifier is_admin {
        require(check_if_admin());
        _;
    }

    modifier is_author {
        require(check_if_signed_up());
        _;
    }
    
    function check_if_admin() private view returns(bool) {
        return admins[msg.sender];
    }
    
    function add_admin (address _admin) public is_owner {
        require(!admins[_admin]);
        admins[_admin] = true;
    }
    
    function remove_admin (address _admin) public is_owner {
        require(_admin != owner);
        require(admins[_admin]);
        delete admins[_admin];
    }
    
    function sign_up(string memory _name) public {
        require(!check_if_signed_up());
        authors[msg.sender] = new Author(this, _name);
        signed_up[msg.sender] = true;
    }
    
    function check_if_signed_up() public view returns(bool) {
        return signed_up[msg.sender];
    }
    
    function publish (string memory _kind, string memory _hash) is_author public {
        require(!check_if_published(_hash));
        authors[msg.sender].publish(_kind, _hash);
        published[_hash] = true;
    }
    
    function check_if_published(string memory _hash) public view returns(bool) {
        return published[_hash];
    }
    
    function check_if_published(address author, string memory _hash) public view returns(bool) {
        if(!signed_up[author]) {
            return false;
        }
        return authors[author].check_if_published(_hash);
    }
}