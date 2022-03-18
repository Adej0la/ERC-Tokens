async function main() {
  const ERC20Token = await hre.ethers.getContractFactory("SubaruERC20");
  const fungible = await ERC20Token.deploy();

  console.log("Fungible Contract has been deployed to:", fungible.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
