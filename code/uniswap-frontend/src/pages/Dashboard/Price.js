import React from 'react';
import CountUp from 'react-countup';
import { useCountUp } from 'react-countup';
import styled from 'styled-components'

import { useExchangeContract } from '../../hooks'
import Typography from '@material-ui/core/Typography';
import Box from '@material-ui/core/Box';

import MonetizationOn from '@material-ui/icons/MonetizationOn';

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
let initialized = false

export default function Price() {
  const contract = useExchangeContract("0x194B23aA2EC27b50A1f7d6c31E8971EDd3848095")

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

  async function updatePrice() {
    contract.ethPool().then(response => {
      let E = response
      contract.tokenPool().then(response => {
	let T = response
	let price = E*(1/(T-1))
	console.log("E = ", parseInt(E._hex), "T = ", parseInt(T._hex))
        update(price)
      })
    })
  }

  function initializeValue() {
    console.log("INIT")
    updatePrice()
  }

  // Initialize event
  if (!initialized) {
    initializeValue()
    // Update every 5sec
    setInterval(function() {
      updatePrice()
    }, 5000);
    initialized = true;
  }

  return (
	<CustomCardContentsWrapper>
	  <Typography component="div">
            <Box fontSize="h6.fontSize" letterSpacing={6} m={1} id="title">
              <MonetizationOn /> Current Price
            </Box>
            <Box textAlign="right" fontWeight="fontWeightBold" fontSize="6vh" m={1} id="bodytext">
	      {countUp} <span id="unit">wei/W</span>
            </Box>
	  </Typography>
	</CustomCardContentsWrapper>
  );
}

