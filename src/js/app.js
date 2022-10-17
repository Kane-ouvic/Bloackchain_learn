App = { // 整個是 JS object
  web3Provider: null,
  contracts: {},

  init: function() {
    return App.initWeb3();
  },

  initWeb3: async function() {
    
    if (window.ethereum) { // 與新的 metamask 互動 (EIP-1193 -> 2018 規範)
      App.web3Provider = window.ethereum;
      try {
        await window.ethereum.enable(); // 詢問使用者是否授權 access
        /* 偵測Metamask有沒有偵測換地址這件事情，如果有的話，重新載入網頁 */
        window.ethereum.on('accountsChanged', function (accounts) {
          window.location.reload()
        })
      } catch (error) {
        console.error("User denied account access") // 使用者拒絕
      }
    }else if (window.web3) { // 舊版的互動方式
      App.web3Provider = window.web3.currentProvider;
    }else { // 都沒有就本地端 Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    /* 原本是Bank.json，因為改成Erc20Bank以後，編譯出來的json變的不一樣了，所以要把他改過去 */
    // $.getJSON('Bank.json', function(data) { 
    $.getJSON('Erc20Bank.json', function(data) { // 我們 deploy 完成後，build/ 裡面應該出現
      var BankArtifact = data;
      App.contracts.Bank = TruffleContract(BankArtifact);  // 透過 truffle-contract 的功能
      // 會自動抓 abi 與 address (truffle 在 network 欄位會存) 建立合約的 instance

      // Set the provider for our contract.
      App.contracts.Bank.setProvider(App.web3Provider);

      // Use our contract to retieve and mark the adopted pets.
      return App.getBalances();
    });

    return App.bindEvents();
  },

  bindEvents: function() { // jQuery
    $(document).on('click', '#transferButton', App.handleTransfer);
    $(document).on('click', '#mintButton', App.handleMint);
    $(document).on('click', '#transferFromButton', App.handleTransferFrom);
    $(document).on('click', '#approveButton', App.handleApprove);
  },

  handleTransfer: function(event) {
    event.preventDefault();

    var amount = parseInt($('#TransferAmount').val());
    var toAddress = $('#HTTransaferAddress').val();

    console.log('Transfer ' + amount + ' TT to ' + toAddress);

    var BankInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Bank.deployed().then(function(instance) {
        BankInstance = instance;

        return BankInstance.transfer(toAddress, amount, {from: account, gas: 100000});
      }).then(function(result) {
        alert('Transfer Successful!');
        return App.getBalances();
      }).catch(function(err) {
        alert(err.message);
        console.log(err.message);
      });
    });
  },
  
  handleMint: function(event) {
    event.preventDefault();

    var amount = parseInt($('#MintReceiverAmount').val());
    var toAddress = $('#MintReceiverAddress').val();

    console.log('Mint ' + amount + ' coins to ' + toAddress);

    var BankInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];

      App.contracts.Bank.deployed().then(function(instance) {
        BankInstance = instance;

        return BankInstance.mint(toAddress, amount, {from: account, gas: 100000});
      }).then(function(result) {
        alert('Mint Successful!');
        return App.getBalances();
      }).catch(function(err) {
        alert(err.message);
        console.log(err.message);
      });
    });
  },

  handleTransferFrom: function(event) {
    event.preventDefault();

    var fromAddress = $('#TransferFromAddress').val();
    var toAddress = $('#TransferToAddress').val();
    var amount = parseInt($('#TransferFromAmount').val());

    console.log('Transfer from ' + fromAddress + ' to ' + toAddress + ' with ' +  amount + ' coin');

    var BankInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];

      App.contracts.Bank.deployed().then(function(instance) {
        BankInstance = instance;

        return BankInstance.transferFrom(fromAddress, toAddress, amount, {from: account, gas: 100000});
      }).then(function(result) {
        alert('TransferFrom Successful!');
        return App.getBalances();
      }).catch(function(err) {
        alert(err.message);
        console.log(err.message);
      });
    });
  },

  handleApprove: function(event) {
    event.preventDefault();

    var address = $('#ApproveAddress').val();
    var amount = parseInt($('#ApproveAmount').val());

    console.log('approve ' + address + ' to transfer ' + amount + ' coins');

    var BankInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];

      App.contracts.Bank.deployed().then(function(instance) {
        BankInstance = instance;

        return BankInstance.approve(address, amount, {from: account, gas: 100000});
      }).then(function(result) {
        alert('Approve Successful!');
        return App.getBalances();
      }).catch(function(err) {
        alert(err.message);
        console.log(err.message);
      });
    });
  },

  getBalances: function() {
    console.log('Getting balances...');

    var BankInstance;

    // 獲取帳號
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      // 帳號設定為第一個，metamask 也會將選定的 account 放在第一個位置
      var account = accounts[0];

      App.contracts.Bank.deployed().then(function(instance) {
        BankInstance = instance; // 確認合約有部署並拿到合約 instance

        /* 原本是coin，改過以後要換成balanceOf */
        // return BankInstance.coin(account);
        return BankInstance.balanceOf(account);
      }).then(function(result) {
        balance = result.c[0];
        // 將 id=HTBalance 的內容改為 balance
        $('#HTBalance').text(balance);
      }).catch(function(err) { // 合約沒部署或其他錯誤都會跑到這
        alert(err.message);
        console.log(err.message);
      });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});

