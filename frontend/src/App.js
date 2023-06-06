import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import StakingContract from "./artifacts/contracts/Staking.sol/Staking.json";

function App() {
  const [stakerData, setStakerData] = useState(null);
  const [amount, setAmount] = useState("");
  const [loading, setLoading] = useState(false);
  const [account, setAccount] = useState(""); // Creating a state variable for the account address and initializing it with an empty string
  const [contract, setContract] = useState(null); // Creating a state variable for the smart contract and initializing it with null
  const [provider, setProvider] = useState(null);

  useEffect(() => {
    getStakerData();
  }, []);
  useEffect(() => { // useEffect hook to run the following code when the component mounts
    const provider = new ethers.providers.Web3Provider(window.ethereum); // Creating a new instance of Web3Provider and passing the ethereum object provided by the window object

    const loadProvider = async () => { // Declaring an async function to load the provider
      if (provider) { // Checking if provider exists
        window.ethereum.on("chainChanged", () => { // Listening to the chainChanged event and reloading the page when it is triggered
          window.location.reload();
        });

        window.ethereum.on("accountsChanged", () => { // Listening to the accountsChanged event and reloading the page when it is triggered
          window.location.reload();
        });
        await provider.send("eth_requestAccounts", []); // Sending a request to the user to connect their Ethereum account
        const signer = provider.getSigner(); // Creating a new signer object
        const address = await signer.getAddress(); // Getting the address of the signer object
        setAccount(address); // Setting the account variable to the address
        let contractAddress = "0x359a2ecCb12239350a3508aFCF2adCE3DD56FbdB"; // Storing the address of the deployed smart contract

        const contract = new ethers.Contract( // Creating a new instance of the smart contract and passing the address, ABI, and signer object
          contractAddress,
          dStorage.abi,
          signer
        );
        setContract(contract); // Setting the contract variable to the new instance of the smart contract
        setProvider(provider); // Setting the provider variable to the Web3Provider instance
      } else {
        console.error("Metamask is not installed"); // Logging an error message if provider is null
      }
    };
    provider && loadProvider(); // Calling the loadProvider function if provider exists
  }, []);

  const getStakerData = async () => {
    if (!window.ethereum) return;

    const signer = provider.getSigner();
    const stakingContract = new ethers.Contract(
      contractAddress,
      StakingContract.abi,
      signer
    );

    const stakerAddress = await signer.getAddress();
    const stakerData = await stakingContract.stakers(stakerAddress);
    setStakerData(stakerData);
  };

  const stakeTokens = async () => {
    if (!window.ethereum) return;

    setLoading(true);

    try {
      const signer = provider.getSigner();
      const stakingContract = new ethers.Contract(
        contractAddress,
        StakingContract.abi,
        signer
      );

      const transaction = await stakingContract.stake(ethers.utils.parseEther(amount));
      await transaction.wait();

      setAmount("");
      getStakerData();
    } catch (error) {
      console.error("Error staking tokens:", error);
    }

    setLoading(false);
  };

  const unstakeTokens = async () => {
    if (!window.ethereum) return;

    setLoading(true);

    try {
      const signer = provider.getSigner();
      const stakingContract = new ethers.Contract(
        contractAddress,
        StakingContract.abi,
        signer
      );

      const transaction = await stakingContract.unstake(ethers.utils.parseEther(amount));
      await transaction.wait();

      setAmount("");
      getStakerData();
    } catch (error) {
      console.error("Error unstaking tokens:", error);
    }

    setLoading(false);
  };

  const claimReward = async () => {
    if (!window.ethereum) return;

    setLoading(true);

    try {
      const signer = provider.getSigner();
      const stakingContract = new ethers.Contract(
        contractAddress,
        StakingContract.abi,
        signer
      );

      const transaction = await stakingContract.claimReward();
      await transaction.wait();

      getStakerData();
    } catch (error) {
      console.error("Error claiming reward:", error);
    }

    setLoading(false);
  };

  if (!stakerData) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>Staking App</h1>
      <div>
        <h3>Your Staking Data:</h3>
        <p>Total Staked: {ethers.utils.formatEther(stakerData.totalStaked)}</p>
        <p>Reward: {ethers.utils.formatEther(stakerData.reward)}</p>
      </div>
     
      <div>
        <h3>Stake Tokens:</h3>
        <input
          type="text"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="Enter amount"
        />
        <button onClick={stakeTokens} disabled={loading}>
          Stake
        </button>
      </div>
      <div>
        <h3>Unstake Tokens:</h3>
        <input
          type="text"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="Enter amount"
        />
        <button onClick={unstakeTokens} disabled={loading}>
          Unstake
        </button>
      </div>
      <div>
        <h3>Claim Reward:</h3>
        <button onClick={claimReward} disabled={loading}>
          Claim
        </button>
      </div>
    </div>
  );
}

export default App;
