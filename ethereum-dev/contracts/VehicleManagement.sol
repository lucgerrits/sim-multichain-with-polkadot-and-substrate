// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;
 
/**
    * @title VehicleManagement
    * @dev Vehicle Management for accident use case
    * @custom:dev-run-script scripts/deploy_with_ethers.ts
*/
contract VehicleManagement {
    // State variables
    address public admin; // root/admin address
    mapping(address => uint256) public factories; // Factories table
    mapping(address => Vehicle) public vehicles; // Vehicles table
    mapping(address => bool) public vehicleStatus; // VehicleStatus table
    mapping(bytes32 => bytes32) public accidents; // Accidents table
    mapping(address => uint256) public accidentCount; // Accident count for each vehicle

    // Struct to keep vehicle information
    struct Vehicle {
        address factoryId;
        uint256 creationBlock;
    }

    // Events
    event FactoryStored(address indexed factoryId, address indexed origin);
    event VehicleStored(address indexed vehicleId, address indexed origin);
    event VehicleInitialized(address indexed vehicleId);
    event AccidentStored(bytes32 dataHash, address indexed vehicleId, uint256 count);

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    constructor() {
        admin = msg.sender; // Set the deployer as admin
    }

    // Functions
    function create_factory(address factory_id) external onlyAdmin {
        require(factories[factory_id] == 0, "Factory already stored.");
        factories[factory_id] = block.number;
        emit FactoryStored(factory_id, msg.sender);
    }

    function create_vehicle(address vehicle_id) external {
        require(msg.sender == admin || factories[msg.sender] != 0, "Only factories can create vehicles.");
        require(vehicles[vehicle_id].factoryId == address(0), "Vehicle already stored.");
        vehicles[vehicle_id] = Vehicle({factoryId: msg.sender, creationBlock: block.number});
        emit VehicleStored(vehicle_id, msg.sender);
    }

    function init_vehicle(address vehicle_id) external {
        require(vehicles[vehicle_id].factoryId != address(0), "Unknown vehicle.");
        require(msg.sender == vehicles[vehicle_id].factoryId, "Vehicle does not match origin.");
        vehicleStatus[vehicle_id] = true;
        emit VehicleInitialized(vehicle_id);
    }

    function report_accident(address vehicle_id, bytes32 data_hash) external {
        require(vehicles[vehicle_id].factoryId != address(0), "Vehicle is not registered.");
        require(vehicleStatus[vehicle_id], "Vehicle is not active.");

        // Create a unique key for the accident
        bytes32 accident_key = keccak256(abi.encodePacked(vehicle_id, accidentCount[vehicle_id]));
        require(accidents[accident_key] == 0, "Accident already stored for this vehicle and count.");

        // Store the accident data
        accidents[accident_key] = data_hash;
        // Increment the accident count
        accidentCount[vehicle_id]++;

        // Emit the accident stored event
        emit AccidentStored(data_hash, vehicle_id, accidentCount[vehicle_id]);
    }

    // Helper functions
    function isVehicle(address vehicle_id) external view returns (bool) {
        return vehicles[vehicle_id].factoryId != address(0) && vehicleStatus[vehicle_id];
    }

    function getAccidentCount(address vehicle_id) external view returns (uint256) {
        return accidentCount[vehicle_id];
    }

    // Function to change admin (additional helper function)
    function changeAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }
}