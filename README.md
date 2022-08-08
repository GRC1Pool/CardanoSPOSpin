
Cardano's Stake Pool Operators' Spin: A Tool to help Cardano SPOs to pick 
winner(s) for their airdrops/giveaways/prizes. Tool made and used by GRC1 
Owner Ioannis. Twitter: @Grc1P. Some nice stats: https://grc1.netcount.gr 

=== Donation Addr:                                                                                          
addr1q8dyh94atjwqxgsrwa4ejktgw509vw0unhw0esv84pcyhapv520zt0w539umpjy853dlklnnk3eteg4649kgfrks6f9q6pcg9w 

Feel free to use it for your brilliant ideas !!


Usage: ./CardanoSPOSpin.sh [PARAMS]

PARAMS
        -m|--mainnet : Use this if you want to use Cardano's Mainnet

        -d|--debug   : Use if uou like more details on your screen!!

        -w|--weighted: This flag will start a weighted procedure for
                       selecting winners,based on their stake amount
                       If not selected, a random/equal chance select
                       will be performed

        -p=|--pool=  : You HAVE to use a PoolID, so the script knows
                       on which pool's delegators to work with!!!

        -s=|--spins= : How many winners do you want for your spin?!?

        -z=|--noless=: Exclude Delegators with stake less than this.
                       This value is in lovelaces (Not ADA)

        -e=|--exaddr=: Exclude Delegators. Multiple addresses can be
                       added with commas


EXAMPLES: 

        ./CardanoRoll.sh -m -p=b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40 -d -w -z=10000000000
        Run a weighted roll on pool with poolid: b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40, with debug
        information on, and exclude addresses with stake less than 10k ADA

        ./CardanoRoll.sh -m -p=b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40 -s=5
        Run a simple roll on pool with poolid: b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40, on all
        the delegators, and give me 5 winners

        ./CardanoRoll.sh -m -p=b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40 -d -w -z=5000000000 -e=stake1uxgxua350uepslksm2dnqeaym2f92qy82axr7p98mvaga4sy6w30e,stake1u9p8r8exvwrl6g2rsx2jgu7afvx9rsn96vpg0h2cya6uxtqnk5vkr -n=2
        Run a weighted roll on pool with poolid: b3291d8a4e04835ebaa71e0523b37abe64e4cd2eeea35c0886a2dd40, with debug
        information on, exclude addresses with stake less than 5k ADA, exclude the stake addresses:
        stake1uxgxua350uepslksm2dnqeaym2f92qy82axr7p98mvaga4sy6w30e and stake1u9p8r8exvwrl6g2rsx2jgu7afvx9rsn96vpg0h2cya6uxtqnk5vkr
        and give me 2 winners


Feel free to comment, give feedback, make it faster, push changes, or whatever!
Bare with it since it's an initial release. More nice and useful tools will come soon!

Cheers!
-Ioannis [GRC1]
