import React from 'react';
import styled from 'styled-components'

import Typography from '@material-ui/core/Typography';
import Box from '@material-ui/core/Box';

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
`

export default function Price() {
  return (
	<CustomCardContentsWrapper>
	  <Typography component="div">
            <Box fontSize="h6.fontSize" letterSpacing={6} m={1} id="title">
              Current Price
            </Box>
            <Box textAlign="right" fontWeight="fontWeightBold" fontSize="h3.fontSize" m={1} id="bodytext">
              0.00ETH/W
            </Box>
	  </Typography>
	</CustomCardContentsWrapper>
  );
}

