import { LightSmartContractAccount, getDefaultLightAccountFactoryAddress } from "@alchemy/aa-accounts";
import { AlchemyProvider } from "@alchemy/aa-alchemy";
import { LocalAccountSigner, type Hex, HttpTransport, getDefaultEntryPointAddress, SimpleSmartContractAccount } from "@alchemy/aa-core";
import { chains } from "@alchemy/aa-core";
import { ethers } from "ethers";

type Provider = AlchemyProvider & {
  account: LightSmartContractAccount<HttpTransport> | SimpleSmartContractAccount<HttpTransport>;
};
const _provider: ethers.JsonRpcProvider = new ethers.JsonRpcProvider(
  "https://polygon-mumbai.g.alchemy.com/v2/JqiPQfidlW2G375YrWrZ173N6BsNvMTy",
);
// const erc721Address = "0xe0F676f4fa94092611056D96d3E68e9Bae3e6b1D";
const erc721Address = "0x04Fd87FEFFbB4d28c5c4DB6BCEC041E92AB4dbB3";
const erc721Contract = new ethers.Contract(erc721Address, PiggyBoxAbi);
const chain = chains.polygonMumbai;

const waitOneSec = () =>
  new Promise<void>((resolve) => {
    setTimeout(() => resolve(), 1000);
  });

const createAccount = async (ownerPk: string, index: number) => {
  // The private key of your EOA that will be the owner of Light Account
  const PRIVATE_KEY = ownerPk as `0x${string}`;

  // wallet from private key
  const eoaSigner = LocalAccountSigner.privateKeyToAccountSigner(PRIVATE_KEY);

  // Create a provider to send user operations from your smart account
  const provider = new AlchemyProvider({
    apiKey: "JqiPQfidlW2G375YrWrZ173N6BsNvMTy",
    chain,
  });
  const connectedProvider = provider.connect(
    (rpcClient) =>
      new LightSmartContractAccount({
        chain,
        owner: eoaSigner,
        entryPointAddress: getDefaultEntryPointAddress(chain),
        factoryAddress: getDefaultLightAccountFactoryAddress(chain),
        rpcClient,
        index: ethers.toBigInt(index),
      }),
  );
  const onwerAddress = await connectedProvider.account.getAddress();
  const subAccountAddress = await connectedProvider.getAddress();
  console.log({ onwerAddress, subAccountAddress });
  const GAS_MANAGER_POLICY_ID = "aa96611f-b876-4c9c-a37e-307d5bb57507";
  provider.withAlchemyGasManager({ policyId: GAS_MANAGER_POLICY_ID });

  return connectedProvider;
};

async function mintPiggyBox(provider: Provider) {
  const address = await provider.getAddress();
  const callData: string = erc721Contract.interface.encodeFunctionData("mint", [address]);
  const feeData = await _provider.getFeeData();
  const sendUserOperationResult = await provider.sendUserOperation(
    {
      target: erc721Address,
      data: callData as Hex,
    },
    {
      maxFeePerGas: feeData.maxFeePerGas as bigint,
      maxPriorityFeePerGas: feeData.maxPriorityFeePerGas as bigint,
    },
  );
  console.log("UserOperation Hash: ", sendUserOperationResult.hash); // Log the user operation hash
  await waitOneSec();
  // Wait for the user operation to be mined
  const txHash = await provider.waitForUserOperationTransaction(sendUserOperationResult.hash);
  console.log("Transaction Hash: ", txHash); // Log the transaction hash
  const txn = await provider.getTransaction(txHash);
}

// async function batchIncreaseMintBalance(
//   ownerProvider: Provider,
//   wallets: string[]
// ) {
//   const callData: string = erc721Contract.interface.encodeFunctionData(
//     "batchIncreaseMintBalance",
//     [wallets, 1]
//   );
//   const sendUserOperationResult = await ownerProvider.sendUserOperation({
//     target: erc721Address,
//     data: callData as Hex,
//     value: Utils.parseEther("0").toBigInt() as any,
//   });
//   console.log("UserOperation Hash: ", sendUserOperationResult.hash); // Log the user operation hash
//   await waitOneSec();

//   // Wait for the user operation to be mined
//   const txHash = await ownerProvider.waitForUserOperationTransaction(
//     sendUserOperationResult.hash
//   );
//   console.log("Transaction Hash: ", txHash); // Log the transaction hash
//   const txn = await ownerProvider.getTransaction(txHash);
//   console.log(txn.gas);
// }

(async () => {
  // const ownerProvider = await createAccount(
  //   "0xae0e46b65024420d36da52f759c7f37a1a50608e1d46bab95674d3902da99b04"
  // );
  // console.log("Account: ", await ownerProvider.getAddress());

  const providers: Array<Provider> = [];
  const wallets: string[] = [];

  const { privateKey: ownerPk, address } = ethers.Wallet.createRandom();
  console.log("Owner wallet private key: ", ownerPk);
  console.log("Owner wallet address: ", address);
  // for (let i = 0; i < 10; i++) {
  //   const userProvider = await createAccount(ownerPk, i);
  //   providers.push(userProvider);
  //   const address = await userProvider.getAddress();
  //   console.log("User wallet address: ", address);
  //   wallets.push(address);
  // }
  // console.log("Wallets: ", wallets.length);

  // // console.log("Batching the increase mint balance");
  // // await batchIncreaseMintBalance(ownerProvider, [
  // //   ...wallets,
  // //   "0xC920194b762DBb3bb52232096300CF0C59a8Ba88",
  // // ]);

  // for (const userProvider of providers) {
  //   console.log("--------------------");
  //   console.log(
  //     "User Smart Contract Account: ",
  //     await userProvider.getAddress()
  //   );
  //   await mintPiggyBox(userProvider);
  // }
})();
