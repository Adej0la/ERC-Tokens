async function main() {
  const ERC721Token = await hre.ethers.getContractFactory("SubaruERC721");
  const nonFungible = await ERC721Token.deploy();

  console.log(
    "Non-fungible Contract has been deployed to:",
    nonFungible.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
