// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
// いくつかの OpenZeppelin のコントラクトをインポートします。
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    // OpenZeppelin が tokenIds を簡単に追跡するために提供するライブラリを呼び出しています
    using Counters for Counters.Counter;

    // _tokenIdsを初期化（_tokenIds = 0）
    Counters.Counter private _tokenIds;

    uint256 private constant MAX_NUMBER_OF_NFT = 50;

    // SVGコードを作成します。
    // 変更されるのは、表示される単語だけです。
    // すべてのNFTにSVGコードを適用するために、baseSvg変数を作成します。
    string private baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // 3つの配列 string[] に、それぞれランダムな単語を設定しましょう。
    string[] private firstWords = [
        "Nice",
        "Fantastic",
        "Terrible",
        "Crazy",
        "Hysterical",
        "Grand"
    ];
    string[] private secondWords = [
        "Meta",
        "Live",
        "Pop",
        "Cute",
        "Sweet",
        "Hot"
    ];
    string[] private thirdWords = [
        "Kitten",
        "Puppy",
        "Monkey",
        "Bird",
        "Panda",
        "Elephant"
    ];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // NFT トークンの名前とそのシンボルを渡します。
    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract.");
    }

    // シードを生成する関数を作成します。
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // 各配列からランダムに単語を選ぶ関数を3つ作成します。
    // pickRandomFirstWord関数は、最初の単語を選びます。
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // pickRandomFirstWord 関数のシードとなる rand を作成します。
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );

        // seed rand をターミナルに出力する。
        console.log("rand seed: ", rand);

        // firstWords配列の長さを基準に、rand 番目の単語を選びます。
        rand = rand % firstWords.length;

        // firstWords配列から何番目の単語が選ばれるかターミナルに出力する。
        console.log("rand first word: ", rand);
        return firstWords[rand];
    }

    // pickRandomSecondWord関数は、2番目に表示されるの単語を選びます。
    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // pickRandomSecondWord 関数のシードとなる rand を作成します。
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    // pickRandomThirdWord関数は、3番目に表示されるの単語を選びます。
    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // pickRandomThirdWord 関数のシードとなる rand を作成します。
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function getCount() public view returns (uint256) {
        return _tokenIds.current();
    }

    function makeAnEpicNFT() public {
        // 現在のtokenIdを取得します。tokenIdは0から始まります。
        uint256 newItemId = _tokenIds.current();

        if (newItemId >= MAX_NUMBER_OF_NFT) {
            return;
        }

        // 3つの配列からそれぞれ1つの単語をランダムに取り出します。
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);

        // MyEpicNFT.sol
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        // 3つの単語を連結して、<text>タグと<svg>タグで閉じます。
        string memory finalSvg = string(
            abi.encodePacked(baseSvg, first, second, third, "</text></svg>")
        );

        // MyEpicNFT.sol
        // JSONファイルを所定の位置に取得し、base64としてエンコードします。
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // NFTのタイトルを生成される言葉（例: GrandCuteBird）に設定します。
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        //  data:image/svg+xml;base64 を追加し、SVG を base64 でエンコードした結果を追加します。
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        // msg.sender を使って NFT を送信者に Mint します。
        _safeMint(msg.sender, newItemId);

        // NFT データを設定します。
        _setTokenURI(newItemId, finalTokenUri);

        // NFTがいつ誰に作成されたかを確認します。
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        // 次の NFT が Mint されるときのカウンターをインクリメントする。
        _tokenIds.increment();

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
