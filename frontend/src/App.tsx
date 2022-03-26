import "./styles/App.css";
import { ethers } from "ethers";
import twitterLogo from "./assets/twitter-logo.svg";
import React, { useCallback, useEffect, useState } from "react";
import contractAddress from "./contracts/contract-address.json";
import { MyEpicNFT, MyEpicNFT__factory } from "./typechain";

const TWITTER_HANDLE = "dkjym";
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
// const OPENSEA_LINK = "";
const TOTAL_MINT_COUNT = 50;

const App: React.VFC = () => {
  const [currentAccount, setCurrentAccount] = useState("");
  const [nftCount, setNftCount] = useState(0);
  const [loading, setLoading] = useState(false);

  const mintNFT = async () => {
    if (nftCount >= TOTAL_MINT_COUNT) {
      alert("Sorry! No more NFT left");
      return;
    }
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = MyEpicNFT__factory.connect(
          contractAddress.ContractAddress,
          signer
        );
        console.log("Going to pop wallet now to pay gas...");
        let nftTxn = await connectedContract.makeAnEpicNFT();
        setLoading(true);
        console.log("Mining...please wait.");
        await nftTxn.wait();

        console.log(
          `Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`
        );
      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchNFTCount = async () => {
    const { ethereum } = window;
    if (!ethereum) {
      console.log("Make sure you have MetaMask!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }
    const provider = new ethers.providers.Web3Provider(ethereum);
    const signer = provider.getSigner();
    const connectedContract = MyEpicNFT__factory.connect(
      contractAddress.ContractAddress,
      signer
    );
    const nftCount = await connectedContract.getCount();
    setNftCount(nftCount.toNumber());
  };

  const checkWalletConnection = async () => {
    const { ethereum } = window;
    if (!ethereum) {
      console.log("Make sure you have MetaMask!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }

    const chainId = await ethereum.request({ method: "eth_chainId" });
    const rinkebyChainId = "0x4";
    if (chainId !== rinkebyChainId) {
      alert("You are not connected to the Rinkeby Test Network!");
      return;
    }

    const accounts = await ethereum.request({ method: "eth_accounts" });
    if (accounts && accounts.length !== 0) {
      const account = accounts[0];
      setCurrentAccount(account);
    } else {
      console.log("No authorized account found");
    }
  };

  const connectWallet = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        alert("Get MetaMask!");
        return;
      }
      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error);
    }
  };

  const onMint = useCallback(async () => {
    console.log("called!!");
    await fetchNFTCount();
    setLoading(false);
    alert("NFTを送りました！");
  }, []);

  useEffect(() => {
    let connectedContract: MyEpicNFT;

    checkWalletConnection().then(fetchNFTCount);

    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      connectedContract = MyEpicNFT__factory.connect(
        contractAddress.ContractAddress,
        signer
      );
      connectedContract.on("NewEpicNFTMinted", onMint);
    }

    return () => {
      if (connectedContract) {
        connectedContract.off("NewEpicNFTMinted", onMint);
      }
    };
  }, [onMint]);

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">My NFT Collection</p>
          <p className="sub-text">あなただけの特別な NFT を Mint しよう💫</p>
          {currentAccount === "" ? (
            <button
              onClick={connectWallet}
              className="cta-button connect-wallet-button"
            >
              Connect to Wallet
            </button>
          ) : (
            <button
              onClick={mintNFT}
              className="cta-button connect-wallet-button"
            >
              Mint NFT
            </button>
          )}
          <p className="sub-text">
            {loading ? (
              <>Minting... Please wait</>
            ) : (
              <>
                これまでに作成されたNFT: {nftCount}/{TOTAL_MINT_COUNT}
              </>
            )}
          </p>

          <p className="sub-text">
            <a
              target="_blank"
              href="https://rinkeby.rarible.com/items/owned"
              rel="noreferrer"
            >
              <button>Rarible でコレクションを表示</button>
            </a>
          </p>
        </div>
        <div className="footer-container">
          <img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{`built on @${TWITTER_HANDLE}`}</a>
        </div>
      </div>
    </div>
  );
};

export default App;
