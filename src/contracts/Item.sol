// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract Item {
    
    struct ItemStruct {
        string id;
        string name;
        uint quantity;
    }



    mapping(string => uint) public idMap;
    ItemStruct[] items;
    uint itemCount;

    function create(string memory _id, string memory _name, uint _quantity) public {
        items.push(ItemStruct(_id, _name, _quantity));
        idMap[_id] = itemCount;
        itemCount++;
    }

    function getItemById(string memory _id) public view returns (ItemStruct memory) {
        uint idx = idMap[_id];
        ItemStruct memory item = items[idx];
        return item;
    }

    function getAll() public view returns (ItemStruct[] memory) {
        return items;
    }

    function update(string memory _id, string memory _name, uint _quantity) public {
        ItemStruct memory item = getItemById(_id);
        item.name = _name;
        item.quantity = _quantity;
    }

}
