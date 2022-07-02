import { expect } from "chai";
import { ethers } from "hardhat";

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const Elog = await ethers.getContractFactory("Elog");
    const elog = await Elog.deploy();
    await elog.deployed();

    const tx = await elog.post("第一篇文", "http://localhost", "文章內容", ["tag1", "tag2"]);
    await tx.wait();

    const post0 = await elog.getPost(0);

    expect(post0.author).to.equal(owner.address);
    expect(post0.title).to.equal("第一篇文");
    expect(post0.coverURL).to.equal("http://localhost");
    expect(post0.content).to.equal("文章內容");
    console.log("timestamp: ", post0.createdAt);

    const tx2 = await elog
      .connect(addr1)
      .post("第二篇文", "http://localhost", "文章內容2", ["tag1", "tag3"]);
    await tx2.wait();

    const post1 = await elog.getPostInfo(1);

    expect(post1.author).to.equal(addr1.address);
    expect(post1.title).to.equal("第二篇文");
    expect(post1.coverURL).to.equal("http://localhost");
    console.log("timestamp: ", post1.createdAt);

    expect((await elog.getAuthorPosts(addr1.address))[0]).to.equal(1);
    expect(await elog.authorPosts(addr1.address, 0)).to.equal(1);

    // console.log(await elog.authorPosts(addr1.address, 0));
    console.log(await elog.getAlltags());
    console.log(await elog.getTag("tag3"));
    console.log(await elog.tokenIdCounter());
  });
});
