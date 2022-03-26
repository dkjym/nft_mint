import { ethers } from "hardhat";

async function main() {
  const factory = await ethers.getContractFactory("MyEpicNFT");
  const contract = await factory.deploy();

  await contract.deployed();

  console.log("contract deployed to:", contract.address);

  // makeAnEpicNFT 関数を呼び出す。NFT が Mint される。
  let txn = await contract.makeAnEpicNFT();
  // Minting が仮想マイナーにより、承認されるのを待つ。
  await txn.wait();
  // makeAnEpicNFT 関数をもう一度呼び出す。NFT がまた Mint される。
  txn = await contract.makeAnEpicNFT();
  // Minting が仮想マイナーにより、承認されるのを待つ。
  await txn.wait();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
