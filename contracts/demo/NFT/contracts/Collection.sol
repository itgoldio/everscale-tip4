pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import '../../../TIP4_3/TIP4_3Collection.sol';
import './Nft.sol';

contract Collection is TIP4_3Collection {

    /// _remainOnNft - the number of crystals that will remain after the entire mint 
    /// process is completed on the Nft contract
    uint128 _remainOnNft = 0.3 ton;

    constructor(
        TvmCell codeNft, 
        TvmCell codeIndex,
        TvmCell codeIndexBasis,
        uint256 ownerPubkey
    ) TIP4_1Collection (
        codeNft
    ) TIP4_3Collection(
        codeIndex,
        codeIndexBasis,
        ownerPubkey
    ) public {
        tvm.accept();
    }

    function mintNft() external virtual {
        require(msg.value > _remainOnNft + 0.1 ton, CollectionErrors.value_is_less_than_required);
        tvm.rawReserve(msg.value, 1);

        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, uint256(_totalSupply));
        address nftAddr = new Nft{
            stateInit: stateNft,
            value: msg.value
        }(
            msg.sender,
            msg.sender,
            _remainOnNft,
            _indexDeployValue,
            _indexDestroyValue,
            _codeIndex
        ); 

        emit NftCreated(
            _totalSupply, 
            nftAddr,
            msg.sender,
            msg.sender, 
            msg.sender
        );

        _totalSupply++;

        msg.sender.transfer({value: 0, flag: 128});
    }

    function setRemainOnNft(uint128 remainOnNft) external virtual onlyOwner {
        _remainOnNft = remainOnNft;
    } 

    function _buildNftState(
        TvmCell code,
        uint256 id
    ) internal virtual override pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Nft,
            varInit: {_id: id},
            code: code
        });
    }

}
