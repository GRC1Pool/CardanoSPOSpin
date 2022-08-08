#!/usr/bin/env bash
#
# ./CardanoSPOSpin.sh v1.0 
#
# =============================================================================
# === Cardano's Stake Pool Operators' Spin: A Tool to help Cardano SPOs to pick 
# === winner(s) for their airdrops/giveaways/prizes. Tool made and used by GRC1 
# === Pool. Author: Ioannis E. Paterakis == jpat@netcount.gr == Twitter: @Grc1P
# === Step by https://grc1.netcount.gr for some nice Cardano network statistics
# =============================================================================
# === If you like this script please consider donating some lovelaces!!!!!!!!!!
# === Donation Addr:                                                                                          
# === addr1q8dyh94atjwqxgsrwa4ejktgw509vw0unhw0esv84pcyhapv520zt0w539umpjy853dlklnnk3eteg4649kgfrks6f9q6pcg9w
# =============================================================================
# ============= Feel free to use it for your brilliant ideas !! ===============
# =============================================================================

# If you don't already have a BlockFrost Project ID please go to:
# https://blockfrost.io/auth/signin
# and create one. This script does minimal requests even
# if being used by a lot of heavy loaded Cardano Stake Pools. BlockFrost's free
# plan is more than enough. If you exceed that plan, please consider buy a plan
# from this wonderful API.

# Please change this value with your BlockFrost's Project ID:
export PROJECT_ID="ADD_PROJECT_ID_HERE"

################################################
####    DO NOT CHANGE ANYTHING BELOW HERE   ####
################################################

if [[ "${PROJECT_ID:0:7}" != "mainnet" && "${PROJECT_ID:0:7}" != "testnet" ]]; then
	echo "Please Enter a valid BlockFrost Project ID"
	exit 255
fi

PWD="$(dirname "$(readlink -f $0)")";
cd ${PWD}
. ./functions
PARAMS=""

if [[ $# -eq 0 ]] ; then
    usage
    exit 1
fi

while (( "$#" )); do
  case "$1" in
    -m|--mainnet)
      MAINNET=1
      shift
      ;;
    -d|--debug)
      DEBUG=1
      shift
      ;;
    -w|--weighted)
      WGT=1
      shift
      ;;
    -z=*|--excludelessstake=*)
      XZERO="${1#*=}"
      shift
      ;;
    -p=*|--pool=*)
      POOL="${1#*=}"
      shift
      ;;
    -e=*|--excludeaddr=*)
      EXADDRS="${1#*=}"
      shift
      ;;
    -s=*|--spins=*)
      SPINS="${1#*=}"
      shift
      ;;
      *)
       # unknown option
       echo "Unknown Parameter...";echo
       usage
       exit 255;
      ;;
   esac
done

eval set -- "$PARAMS"
  			
runonce=1

disq; echo; sleep 0.5

if ((${#MAINNET[@]})); then
	((DEBUG==1)) && echo; echo -e "We are on Cardano's Mainnet\n"
	BFHOST="cardano-mainnet.blockfrost.io"
else
	((DEBUG==1)) && echo; echo -e "We are on Cardano's Testnet\n"
	BFHOST="cardano-testnet.blockfrost.io"
fi

# if weighted calculation is active, zero stakes MUST be excluded
# since there is no point in being calculated into the chances' map
if ((${#WGT[@]})); then
	if ! [[ -v XZERO[@] ]]; then
		XZERO=1	
	fi
fi

if ((${#EXADDRS[@]})); then
	IFS=', ' read -r -a XADDRARRAY <<< "$EXADDRS"
fi
	
if ! [[ -v SPINS[@] ]]; then
	SPINS=1	
fi
((SPINS<0)) && SPINS=1

if ((${#POOL[@]})); then
  HOWMANYDELS=$(curl --connect-timeout 5 -s -H "project_id: ${PROJECT_ID}" https://${BFHOST}/api/v0/pools/${POOL})
  (( $(echo ${HOWMANYDELS} | jq -rc '.status_code')==403 )) && {
	echo "Please check your Project ID. It must be wrong/invalid"
	exit 255
  }
  #HOWMANYDELS=$(curl --connect-timeout 5 -s -H "project_id: ${PROJECT_ID}" https://${BFHOST}/api/v0/pools/${POOL} |jq -rc '.live_delegators')
  HOWMANYDELS=$(echo ${HOWMANYDELS} |jq -rc '.live_delegators')
  BFROSTCALLS=$(echo "(${HOWMANYDELS} / 100) + 1" | bc)

  WILLSTOP=0
  DELEGS=()
  candidates=0
  for n in $(seq 1 $BFROSTCALLS); do
  	TMPJSONRESULTS=$(curl --connect-timeout 5 -s -H "project_id: ${PROJECT_ID}" https://${BFHOST}/api/v0/pools/${POOL}/delegators?page=$n | jq -rc)
        if [[ $(echo "${TMPJSONRESULTS}" | jq length) != 100 ]]; then
                WILLSTOP=1
        fi
        echo "===== BlockFrost Page: [${n}/${BFROSTCALLS}, Rows: $(echo "${TMPJSONRESULTS}" | jq length)]"
        TMPARRAY=()
        readarray -t TMPARRAY < <(jq -c '.[]' <<< $TMPJSONRESULTS)
        for items in "${TMPARRAY[@]}"; do

                TMPADDRESS=$(jq -r '.address' <<< "$items")
                TMPLIVESTAKE=$(jq -r '.live_stake' <<< "$items")
		bypass=0
	   	if [[ -v XADDRARRAY[@] ]]; then
			for tmparr in "${XADDRARRAY[@]}"; do
				if [[ "$tmparr" == "$TMPADDRESS" ]]; then
					bypass=1
					break;		
				fi
			done
	   	fi
	   	if [[ -v XZERO[@] ]]; then
			(( $(bc <<<"$TMPLIVESTAKE < $XZERO") )) && bypass=1;
	   	fi

		((DEBUG==1)) && {
                 ((bypass==0)) && {
			echo "Candidate [$candidates], Stake Address: [$TMPADDRESS], Live Stake: [$TMPLIVESTAKE]";
			candidates=$((candidates+1))
		  } || { 
			echo "EXCLUDING Stake Address: [$TMPADDRESS], Stake: [$TMPLIVESTAKE]";
		  }
		}

        	((bypass==0)) && DELEGS+=($(echo "${TMPADDRESS}:${TMPLIVESTAKE}"))
        done

    if [[ $WILLSTOP == 1 ]]; then
        break;
    fi
  done

  # Some statistical data
  TOTALSTAKE=0
  for items in "${DELEGS[@]}"; do
	TOTALSTAKE=$(echo "$TOTALSTAKE" '+' "$(echo ${items} | gawk -F ":" '{print $2}')" | bc -l)
  done

  echo; echo "Number of candidate delegators: ${#DELEGS[@]}, with Total Stake: ${TOTALSTAKE} lovelaces [$(echo "scale=2; ${TOTALSTAKE}/1000000" | bc) ADA]"

  echo;
  if ((${#WGT[@]})); then
  	echo "Starting a Weighted roll procedure."
	sleep 0.05
  	echo -n "Applying weights..."

	PERCENTAGE=()	
	smallestnum=1
	for n in "${DELEGS[@]}"; do	
		PERCENTAGE+=($(echo "$(echo ${n}|gawk -F ":" '{print $1}'):$(echo "scale=18; $(echo ${n}|gawk -F ":" '{print $2}')/${TOTALSTAKE}" | bc)"))
		(( $(bc <<<"$(echo "scale=18; $(echo ${n}|gawk -F ":" '{print $2}')/${TOTALSTAKE}" | bc) < $smallestnum") )) && smallestnum="$(echo "scale=18; $(echo ${n}|gawk -F ":" '{print $2}')/${TOTALSTAKE}" | bc)";
	done

	echo "Smallest percentage: [$smallestnum]"
	echo -n "Normalizing values..."
	NORMALIZEDSHARES=()
	maxnum=0
	sumnum=0
	for n in "${DELEGS[@]}"; do	
		NORMALIZEDSHARES+=($(echo "$(echo ${n}|gawk -F ":" '{print $1}'):`printf %.0f $(echo "scale=18; ($(echo ${n}|gawk -F ":" '{print $2}')/${TOTALSTAKE})/${smallestnum}" | bc)`"))

		(( $(bc <<<"`printf %.0f $(echo "scale=18; ($(echo ${n}|gawk -F ":" '{print $2}')/${TOTALSTAKE})/${smallestnum}" | bc)` > $maxnum") )) && maxnum="`printf %.0f $(echo "scale=18; ($(echo ${n}|gawk -F ":" '{print $2}')/${TOTALSTAKE})/${smallestnum}" | bc)`"
		sumnum="`printf %.0f $(echo "scale=18; (($(echo ${n}|gawk -F ":" '{print $2}')/${TOTALSTAKE})/${smallestnum}) + ${sumnum}" | bc)`"
	done
	echo "Done."

	((DEBUG==1)) && {
	   echo; echo "Array of Shares"
	   echo "------------------------------------------------------------------"
	   for n in "${NORMALIZEDSHARES[@]}"; do	
		echo "${n}"	
	   done
	   echo "------------------------------------------------------------------"
	   echo "Max Share: [${maxnum}], out of Total Shares: [${sumnum}]"
	   echo "------------------------------------------------------------------"
	   echo
	}
	tmpsumnum=${sumnum}

	# Chance to abort early if we have a lot of data to progress thus a lot of time
	# to complete the procedure...
	(( ${tmpsumnum} > 90000 )) && { 
	   read -n 1 -r -p "The script will take LONG time to finish depending on the data fetched. Abort Now? [Y/n] " response
	   echo    
	   response=${response,,} 
 	   if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
		echo "You can refine your Spins by let's say excluding the so called \"whale\" delegators"
		echo "or define a minimum stake as a parameter, or maybe try the equal non-weighted spin."
		echo "Weighted Spins make sense only if the Candidates' stakes are close to each other,"
		echo "otherwise the \"weights\" f the \"whales\" will be large and their chances to win"
		echo "will be disproportionately unfair to the rest of the Candidates."
		echo
		echo "Exiting..."
		exit 255
	   else
		echo "You can always stop the procedure by pressing Ctrl+C"; echo
 	   fi
	}
	
	# initialize large string index
	# we're using local files here since arrays have limited memory size
	# and we may come up with very large databases...
	echo "Generating chances' map. This will take A LOT of time, based on your Delegators. Please wait..."
	rm -f ./mapfile.txt
	rm -f ./seq*

	. <(curl --connect-timeout 5 -sLo- "https://git.io/progressbar") && BAR=1 || BAR=0

	((BAR==1)) && bar::start
	((BAR==1)) && trapctrlc
	SECONDS=0
	MaxSteps="`printf %.0f $(echo "scale=18; ${tmpsumnum}*2" | bc)`"

	while (( $(bc <<<"${sumnum} >= 1") )); do
		echo "${sumnum}" >> ./mapfile.txt
		sumnum="`printf %.0f $(echo "scale=18; ${sumnum} - 1" | bc)`"
		StepsDone=$((${StepsDone:-0}+1))
		((BAR==1)) && bar::status_changed $StepsDone $MaxSteps
		# calculate Estimated Time Left for this procedure
                if [[ "$SECONDS" == "5" && "$runonce" == "1" ]]; then
		       ETLSECONDS="`printf %.0f $(echo "scale=18; ((5 * $MaxSteps)/$StepsDone)*2" | bc)`"
		       echo "ETL: $(displaytime $ETLSECONDS)"
		       runonce=0;
                fi
	done

	SECONDS=0
	CurrSteps="$StepsDone"
	for n in "${NORMALIZEDSHARES[@]}"; do	
		tmpaddr=$(echo ${n}|gawk -F ":" '{print $1}')
		tmpvotes=$(echo ${n}|gawk -F ":" '{print $2}')
		while (( $(bc <<<"${tmpvotes} >= 1") )); do
			maxrand=$(egrep -x '[0-9]+' ./mapfile.txt | wc -l)	
  			pickednum=$(rand $(( ${maxrand} - 1 )) )
			pickednum="`printf %.0f $(echo "scale=18; ${pickednum} + 1" | bc)`"
			fileposnum=$(egrep -x '[0-9]+' ./mapfile.txt | sed "${pickednum}q;d")

			sed -i "s/\<${fileposnum}\>/${fileposnum}:${tmpaddr}/g" ./mapfile.txt

			tmpvotes="`printf %.0f $(echo "scale=18; ${tmpvotes} - 1" | bc)`"

			StepsDone=$((${StepsDone:-0}+1))
			((BAR==1)) && bar::status_changed $StepsDone $MaxSteps
			# calculate Estimated Time Left for this procedure
                	if [[ "$SECONDS" == "5" && "$runonce" == "0" ]]; then
		       		ETLSECONDS="`printf %.0f $(echo "scale=18; (5 * ($MaxSteps - $CurrSteps))/($StepsDone - $CurrSteps)" | bc)`"
		       		echo "ETL: $(displaytime $ETLSECONDS)"
		       		runonce=1;
                	fi
        	done	
	done

	((BAR==1)) && bar::stop
	((BAR==1)) && untrapctrlc

	echo "Rolling the dice...."

	maxrand=$(wc -l ./mapfile.txt | gawk '{print $1}')	

	(( ${#NORMALIZEDSHARES[@]} > ${SPINS} )) && {
	   while (( $(bc <<<"${SPINS} >= 1") )); do
		SPINS="`printf %.0f $(echo "scale=18; ${SPINS} - 1" | bc)`"

  		pickednum=$(($(rand $(( ${maxrand} - 1 )) ) + 1))
		echo -n "[$pickednum], "
		winner=$(awk "FNR==$pickednum" ./mapfile.txt)	
		echo -n "Winner Address: [$(echo $winner |gawk -F ":" '{print $2}')]"

		for n in "${NORMALIZEDSHARES[@]}"; do	
			if [[ "$(echo $winner |gawk -F ":" '{print $2}')" == "$(echo ${n} | gawk -F ":" '{print $1}')" ]] ; then
				chanceofwin="`printf %.2f $(echo "scale=18; ($(echo ${n} | gawk -F ":" '{print $2}') / ${tmpsumnum})*100" | bc)`"
				break;
			fi
		done
		echo ", Chance: [${chanceofwin}%]"

		sed -i "/$(echo $winner |gawk -F ":" '{print $2}')/d" ./mapfile.txt
		maxrand=$(wc -l ./mapfile.txt | gawk '{print $1}')	

	   done
	} || {
		((SPINS>1)) && echo "Candidate Delegators are less or equal than the spins. All winning: " ; echo
		for n in $(seq 0 $(echo "${#NORMALIZEDSHARES[@]}-1"|bc)); do      
                        echo "WINNER: [$(echo ${NORMALIZEDSHARES[$n]} | gawk -F ":" '{print $1}')]" 
                done
	}
  else
  	echo "Picking up Winner(s) in an Equal roll..."; echo
	
  	((${#DELEGS[@]}>0)) && {
	   (( ${#DELEGS[@]} > ${SPINS} )) && {
	      while (( $(bc <<<"${SPINS} >= 1") )); do
		SPINS="`printf %.0f $(echo "scale=18; ${SPINS} - 1" | bc)`"

  		WHONUM=$(rand $(( ${#DELEGS[@]} - 1 )) )

  		echo "WINNER: [$(echo ${DELEGS[$WHONUM]} | gawk -F ":" '{print $1}')]" 
		
		# Removing already chosen winner from array	
		delete="${DELEGS[$WHONUM]}"
		for target in "${delete[@]}"; do
  		  for i in "${!DELEGS[@]}"; do
    		    if [[ ${DELEGS[i]} = $target ]]; then
      		      unset 'DELEGS[i]'
    		    fi
  		  done
		done
		# filling gaps
		for i in "${!DELEGS[@]}"; do
   	 	  tmp_array+=( "${DELEGS[i]}" )
		done
		DELEGS=("${tmp_array[@]}")
		unset tmp_array

	      done
	   } || {
		((SPINS>1)) && echo "Candidate Delegators are less or equal than the spins. All winning: " ; echo
		for n in $(seq 0 $(echo "${#DELEGS[@]}-1"|bc)); do	
  			echo "WINNER: [$(echo ${DELEGS[$n]} | gawk -F ":" '{print $1}')]" 
		done
	   }
	} || echo "No Applicable Delegators left. Aborting.";
  fi

else
	echo "Please use a PoolID"
	exit 255;
fi


echo
exit 0

