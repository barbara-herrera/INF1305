pragma solidity ^0.5.8;


contract EasyStorage {

  // Informações gerais do contrato
  address payable private contract_owner_address; // dono e criador do contrato
  string private contract_title; // titulo do contrato
  string private contract_description; // descrição do contrato para melhor entendimento do msm

  uint private contract_price_to_rent_unit_storage; // 100 finney
  uint private contract_price_to_add_storage_owner; // 100 finney

  // Struct que representa as informações do contrato de aluguel de Storage
  struct Storage {
    address payable storage_owner_address;
    address payable storage_tenant_adrress;
    uint storage_units; // unit é a menor medida de armazenamento
    uint initial_date; 
    uint final_date;	  
  }

  // Fornecendo um id, eu identifico um contrato de armazenamento
  Storage[] private storage_list;
  
  // Lista para identificar os donos de armazens, se não estiver na lista, esse dono não foi registrado
  // o segundo parametro indica o total de unidades disponíveis que o armazém do dono tem
  mapping(address => uint) private storage_owners_list;
  

   constructor() public {
    contract_owner_address = msg.sender;
    contract_title = "Titulo do Contrato Aluguel de Armazenamento.";
    contract_description = "Contrato para aluguel de armazenamentos.";
    contract_price_to_rent_unit_storage = 100 finney;
	contract_price_to_add_storage_owner = 100 finney;
  }

  modifier isContractOwner {
    require(msg.sender == contract_owner_address, "Somente o dono do contrato pode chamar esta função.");
    _;
  }
  
  modifier isStorageOwner {
    require(storage_owners_list[msg.sender] >= 0, "O endereço de proprietário de armazém informado não existe.");
    _;
  }
  
  modifier isStorageAvailableOwner {
    require(storage_owners_list[msg.sender] >= 0, "Este armazém não possui mais espaços disponíveis.");
    _;
  }
  
  // Seta o titulo do contrato
  function setContractTitle(string memory _contract_title) public isContractOwner {
    contract_title = _contract_title;
  }

  // Seta a descrição do contrato
  function setContractDescription(string memory _contract_description) public isContractOwner {
    contract_description = _contract_description;
  }

  // Seta o endereço do dono deste contrato
  function setContractOwnerAddress(address payable _contract_owner_address) public isContractOwner {
    contract_owner_address = _contract_owner_address;
  }

  // Seta o preço para adicionar um novo dono de armazem. Cada dono de armazem deve adicionar  dono do espaço que irá disponibilizar para alugar
  function setContractPriceToAddStorageOwner(uint _contract_price_to_add_storage_owner) public isContractOwner {
    contract_price_to_add_storage_owner = _contract_price_to_add_storage_owner;
  }


  // Adiciona um dono de storage para ser usado nos contratos
  function addStorageOwner(uint _storage_units) public payable {
      require(storage_owners_list[msg.sender] == 0, "Storage já possui dono");
      require(msg.value == contract_price_to_add_storage_owner, "Preço para adicionar um novo dono de armazém incorreto");

      storage_owners_list[msg.sender] = _storage_units;
      
	  contract_owner_address.transfer(msg.value);
  }

  // Contrato de aluguel de um espaço em armazém
  function rentStorage(address payable _storage_owner, uint _storage_units, uint _initial_date, uint _final_date) public payable {
    require(storage_owners_list[_storage_owner] != 0, "Esta Storage não existe ou o armazém nãp possui mais espaços para alugar!");
    require(contract_price_to_rent_unit_storage == msg.value, "Valor para criar um contrato de aluguel de storage errado!");
    
    uint tam = storage_list.length;
    storage_list[tam].storage_owner_address = _storage_owner;
    storage_list[tam].storage_units = _storage_units;
    
    storage_list[tam].storage_owner_address.transfer(msg.value);

    storage_list[tam].storage_tenant_adrress = msg.sender;
    
    storage_list[tam].initial_date = _initial_date;
    storage_list[tam].final_date = _final_date;
  }

  function getContractTitle() public view returns (string memory) {
    return contract_title;
  }

  function getContractDescription() public view returns (string memory) {
    return contract_description;
  }

  function getContractOwnerAddress() public view returns (address) {
    return contract_owner_address;
  }

  function getContractPriceToAddStorageOwner() public view returns (uint256) {
    return contract_price_to_add_storage_owner;
  }

  function getPriceToRentStorage() public view returns (uint) {
    return contract_price_to_rent_unit_storage;
  }

  function getStorageOwnerUnits() public view returns (uint) {
    return storage_owners_list[msg.sender];
  }

  function getStorageTenant(uint _id_storage_list) public view returns (address) {
    return storage_list[_id_storage_list].storage_tenant_adrress;
  }

  function killContract() public isContractOwner() {
	contract_owner_address.transfer(address(this).balance);
	selfdestruct(contract_owner_address);
  }
}
