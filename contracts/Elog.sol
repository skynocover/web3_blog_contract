// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Elog is ERC721, Ownable {
  using Counters for Counters.Counter;

  Counters.Counter public tokenIdCounter;

  constructor() ERC721("Elog", "ELG") {}

  function safeMint(address to) public onlyOwner {
    uint256 tokenId = tokenIdCounter.current();
    tokenIdCounter.increment();
    _safeMint(to, tokenId);
  }

  // Post的結構
  struct Post {
    string title; // 書名
    address author; // 作者(地址)
    string coverURL; // 封面
    string content; // 內容
    string[] tags; // tags
    uint256 createdAt; // timestamp
  }

  // tag-tokenId 對應表
  mapping(string => uint256[]) private _tagPosts;

  // tags
  string[] private _alltags;

  // tokenId-post 對應表
  mapping(uint256 => Post) private _posts;

  // 作者-tokenId 對應表
  mapping(address => uint256[]) public authorPosts;

  // 用戶發布Post
  function post(
    string calldata title,
    string calldata coverURL,
    string calldata content,
    string[] calldata tags
  ) public payable returns (uint256) {
    uint256 tokenId = tokenIdCounter.current();
    tokenIdCounter.increment();

    // change now to https://github.com/pipermerriam/ethereum-datetime on mainnet
    _posts[tokenId] = Post(title, msg.sender, coverURL, content, tags, block.timestamp);
    for (uint256 i = 0; i < tags.length; i++) {
      if (_tagPosts[tags[i]].length == 0) {
        _alltags.push(tags[i]);
      }
      _tagPosts[tags[i]].push(tokenId);
    }
    authorPosts[msg.sender].push(tokenId);

    _mint(msg.sender, tokenId);
    return tokenId;
  }

  // 取得用戶Post
  function getAuthorPosts(address author) public view returns (uint256[] memory) {
    return authorPosts[author];
  }

  // 取得所有的tag
  function getAlltags() public view returns (string[] memory) {
    return _alltags;
  }

  // 取得tag的Post
  function getTag(string calldata tagName) public view returns (uint256[] memory) {
    return _tagPosts[tagName];
  }

  // 使用tokenId 取得Post
  function getPost(uint256 tokenId) public view returns (Post memory) {
    return _posts[tokenId];
  }

  // PostInfo
  struct PostInfo {
    string title; // 書名
    address author; // 作者(地址)
    string coverURL; // 封面
    string[] tags; // tags
    uint256 createdAt; // timestamp
  }

  // 使用tokenId 取得PostInfo
  function getPostInfo(uint256 tokenId) public view returns (PostInfo memory) {
    return
      PostInfo(
        _posts[tokenId].title,
        _posts[tokenId].author,
        _posts[tokenId].coverURL,
        _posts[tokenId].tags,
        _posts[tokenId].createdAt
      );
  }
}
