mod DeployerHelper {
    use snforge_std::{
        ContractClass, ContractClassTrait, CheatTarget, declare, start_prank, stop_prank
    };
    use starknet::{ContractAddress, ClassHash, contract_address_const};
    use unruggable::amm::amm::AMM;

    fn deploy_contracts() -> (ContractAddress, ContractAddress) {
        let deployer = contract_address_const::<'DEPLOYER'>();
        let pair_class = declare('PairC1');

        let mut factory_constructor_calldata = Default::default();

        Serde::serialize(@pair_class.class_hash, ref factory_constructor_calldata);
        Serde::serialize(@deployer, ref factory_constructor_calldata);
        let factory_class = declare('FactoryC1');

        let factory_address = factory_class.deploy(@factory_constructor_calldata).unwrap();

        let mut router_constructor_calldata = Default::default();
        Serde::serialize(@factory_address, ref router_constructor_calldata);
        let router_class = declare('RouterC1');

        let router_address = router_class.deploy(@router_constructor_calldata).unwrap();

        (factory_address, router_address)
    }

    fn deploy_unruggable_memecoin_contract(
        owner: ContractAddress,
        recipient: ContractAddress,
        name: felt252,
        symbol: felt252,
        initial_supply: u256,
        amms: Array<AMM>
    ) -> ContractAddress {
        let contract = declare('UnruggableMemecoin');
        let mut constructor_calldata = array![
            owner.into(),
            recipient.into(),
            name,
            symbol,
            initial_supply.low.into(),
            initial_supply.high.into(),
        ];
        contract.deploy(@constructor_calldata).unwrap()
    }

    fn deploy_memecoin_factory(
        owner: ContractAddress, memecoin_class_hash: ClassHash, amms: Array<AMM>
    ) -> ContractAddress {
        let contract = declare('UnruggableMemecoinFactory');
        let mut calldata = array![];
        calldata.append(owner.into());
        calldata.append(memecoin_class_hash.into());
        Serde::serialize(@amms.into(), ref calldata);

        contract.deploy(@calldata).unwrap()
    }

    fn deploy_erc20(initial_supply: u256, recipient: ContractAddress) -> ContractAddress {
        let erc20_class = declare('ERC20Token');

        let mut token0_constructor_calldata = Default::default();
        Serde::serialize(@initial_supply, ref token0_constructor_calldata);
        Serde::serialize(@recipient, ref token0_constructor_calldata);

        erc20_class.deploy(@token0_constructor_calldata).unwrap()
    }
}
