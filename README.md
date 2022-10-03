
Cardano's Stake Pool Operators' Spin: 

A Tool to help Cardano SPOs (and not just them!) to pick winner(s) among their delegators for their airdrops/giveaways/prizes. 

Tool made and used by GRC1 Owner Ioannis. 

Twitter: @Grc1P. 

Step by https://grc1.netcount.gr for some nice statistics about Cardano's network (updated daily).

If you like this script consider splitting some love(laces) by donating to the address below!

Changes: 
- v1.1: Added options to include filters regarding assetIDs/policyIDs in Delegators' wallets
- v1.0: Initial Release

=== Donation Addr:                                                                                          
addr1q8dyh94atjwqxgsrwa4ejktgw509vw0unhw0esv84pcyhapv520zt0w539umpjy853dlklnnk3eteg4649kgfrks6f9q6pcg9w 




Usage: ./CardanoSPOSpin.sh [PARAMS]

PARAMS

        -m|--mainnet : Use this if you want to use Cardano's Mainnet

        -d|--debug   : Use if you like more details on your screen!!

        -w|--weighted: This flag will start a weighted procedure for
                       selecting winners,based on their stake amount
                       If not selected , an equal chances' draw will
                       be performed

        -p=|--pool=  : You HAVE to use a PoolID, so the script knows
                       on which pool's delegators to work with!!!

        -s=|--spins= : How many winners do you want for your spin?!?

        -z=|--noless=: Exclude Delegators with stake less than this.
                       This value is in lovelaces (Not ADA)

        -e=|--exaddr=: Exclude Delegators. Multiple addresses can be
                       added with commas

        -b=|--policy=: Include Delegators that have *assets* of this
                       policyID in their wallets. Multiple policyIDs
                       can be added here with commas

        -a=|--asset= : Include Delegators that have this asset ID in
                       in their wallet addresses. Multiple asset IDs 
                       can be added with commas



EXAMPLES: 

        ./CardanoSPOSpin.sh -m -p=b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40 -d -w -z=10000000000
        Run a weighted roll on pool with poolid: b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40, with debug
        information on, and exclude addresses with stake less than 10k ADA

        ./CardanoSPOSpin.sh -m -p=b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40 -s=5
        Run a simple roll on pool with poolid: b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40, on all
        the delegators, and give me 5 winners

        ./CardanoSPOSpin.sh -m -p=b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40 -d -w -z=5000000000 -e=stake1uxgxua350uepslksm2dnqeaym2f92qy82axr7p98mvaga4sy6w30e,stake1u9p8r8exvwrl6g2rsx2jgu7afvx9rsn96vpg0h2cya6uxtqnk5vkr -n=2
        Run a weighted roll on pool with poolid: b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40, with debug
        information on, exclude addresses with stake less than 5k ADA, exclude the stake addresses:
        stake1uxgxua350uepslksm2dnqeaym2f92qy82axr7p98mvaga4sy6w30e and stake1u9p8r8exvwrl6g2rsx2jgu7afvx9rsn96vpg0h2cya6uxtqnk5vkr
        and give me 2 winners

        ./CardanoSPOSpin.sh -m -p=b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40 -d -w -z=5000000000 -e=stake1uxgxua350uepslksm2dnqeaym2f92qy82axr7p98mvaga4sy6w30e,stake1u9p8r8exvwrl6g2rsx2jgu7afvx9rsn96vpg0h2cya6uxtqnk5vkr -n=2 -b=5c80d8420b415e6f277d830e780190f288993019108bebecf5ccf9e1,e6dc9baca01d530b85606ecdd7a1e4317fc080f3b0c807fd70552a80
        Run a weighted roll on pool with poolid: b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40, with debug
        information on, include only the addresses which are owners of any asset that has been minted under these policyIDs:
        5c80d8420b415e6f277d830e780190f288993019108bebecf5ccf9e1, e6dc9baca01d530b85606ecdd7a1e4317fc080f3b0c807fd70552a80 AND
        AND have more than 5k ADA, but exclude the following stake addresses (even if they have more than 5k ADA and/or the above assets:
        stake1uxgxua350uepslksm2dnqeaym2f92qy82axr7p98mvaga4sy6w30e and stake1u9p8r8exvwrl6g2rsx2jgu7afvx9rsn96vpg0h2cya6uxtqnk5vkr
        As a result, draw 2 winners

        ./CardanoSPOSpin.sh -d -m -p=b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40 -z=10000000000 -s=1 -a=c56d4cceb8a8550534968e1bf165137ca41e908d2d780cc1402079bd4368696c6c65644b6f6e6734353839 -b=12e65fa3585d80cba39dcf4f59363bb68b77f9d3c0784734427b1517
        Run an equal (non-weighted) roll on pool with poolid: b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40, with debug
        information on, include only the addresses which are owners of any asset that has been minted under this policyID:
        12e65fa3585d80cba39dcf4f59363bb68b77f9d3c0784734427b1517 OR are owners of this assetID: 
        c56d4cceb8a8550534968e1bf165137ca41e908d2d780cc1402079bd4368696c6c65644b6f6e6734353839 
        AND have more than 10k ADA, but exclude the following stake addresses (even if they have more than 10k ADA and/or the above assets:
        stake1uxgxua350uepslksm2dnqeaym2f92qy82axr7p98mvaga4sy6w30e and stake1u9p8r8exvwrl6g2rsx2jgu7afvx9rsn96vpg0h2cya6uxtqnk5vkr
        As a result, draw 1 winner



Feel free to comment, give feedback, make it faster, push changes, or whatever!
Bare with it since it's in an early stage. More nice and useful tools will come soon!

Cheers!
