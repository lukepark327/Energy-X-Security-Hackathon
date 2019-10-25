import React from 'react';
import CountUp from 'react-countup';
import { useCountUp } from 'react-countup';
import styled from 'styled-components'

//import { useWeb3Context } from 'web3-react'
import { useFactoryContract } from '../../hooks'
import { useTransactionAdder } from '../../contexts/Transactions'

import Typography from '@material-ui/core/Typography';
import Box from '@material-ui/core/Box';

import OfflineBolt from '@material-ui/icons/OfflineBolt';

const CustomCardContentsWrapper = styled.div`
  #title {
    color: ${({ theme }) => theme.charcoalBlack};
    height: 17vh;
  }

  #bodytext {
    color: ${({ theme }) => theme.doveGray}; 
  }

  #learnButton {
    background-color: ${({ theme }) => theme.uniswapPink};
    color: ${({ theme }) => theme.white};
  }

  #unit { 
    font-size: 2.5vh;
    font-weight: normal;
  }
`

let initialized = false;

export default function Prediction() {
  //const { account } = useWeb3Context()
  const factory = useFactoryContract()
  const addTransaction = useTransactionAdder()
  let reqTime = 0;

  const { countUp, start, pauseResume, reset, update } = useCountUp({
    start: 0,
    end: 1234567,
    delay: 1000,
    duration: 1,
    decimals: 3, 
    onReset: () => console.log('Resetted!'),
    onUpdate: () => console.log('Updated!'),               
    onPauseResume: () => console.log('Paused or resumed!'),
    onStart: ({ pauseResume }) => console.log(pauseResume),
    onEnd: ({ pauseResume }) => console.log(pauseResume),
  });

  async function requestInference() {      
    // args : int _reqTime, int[] memory _infos
    reqTime = Math.round((new Date()).getTime()/1000)
    console.log("REQUEST INFERENCE! @", reqTime)
    let args = [reqTime, [1,1,1]]
    factory.requestInference(...args, { gasLimit: 750000 }).then(response => {
      addTransaction(response)
    })
  }

/*
  async function getResponse() {
    // args : reqADDRESS + reqTime
    console.log("GET RESPONSE! @", account + reqTime)
    let args = [account + reqTime]
    factory.getResponse(...args).then(response => {
      console.log(response)
      document.getElementById("predictedValue").innerHTML = response;
    })
  }
*/

  async function updateResponse() {
    factory.latestPredictedPower().then(response => {
      update(response/10000000)
    })
  }

  function initializeValue() {
    console.log("INIT")
    updateResponse()
  }

  // Initialize event
  if (!initialized) {
    initializeValue()
    // Update every 5sec
    setInterval(function() {
      updateResponse()
    }, 5000);
    initialized = true;
  }

  return (
	<CustomCardContentsWrapper>
	  <Typography component="div">
            <Box fontSize="h6.fontSize" letterSpacing={6} m={1} id="title">
              <OfflineBolt onClick={requestInference}/> Prediction Result
            </Box>
            <Box textAlign="right" fontWeight="fontWeightBold" fontSize="6vh" m={1} id="bodytext">
              {countUp} <span id="unit">MW</span>
            </Box>
	  </Typography>
	</CustomCardContentsWrapper>
  );
}

