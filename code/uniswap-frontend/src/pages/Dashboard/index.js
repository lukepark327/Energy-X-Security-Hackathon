import React from 'react';
import styled from 'styled-components'
import Chart from './Chart.js'
import Prediction from './Prediction.js'
import Price from './Price.js'

import Divider from '@material-ui/core/Divider';
import Grid from '@material-ui/core/Grid';
import Card from '@material-ui/core/Card';
import Web3ReactManager from '../../components/Web3ReactManager'

const DashboardWrapper = styled.div`
  #root {
    flexGrow: 1;
  }

  #divider {
    margin: 12px 0 12px 0;
    background-color: ${({ theme }) => theme.chaliceGray};
  }

  #customcard {
    height: 28vh;
    padding: 3vh;
    background-color: ${({ theme }) => theme.concreteGray};
    vertical-align: middle;
  }

  #customcardForChart {
    padding: 25px;
    background-color: ${({ theme }) => theme.concreteGray};
  }
`

export default function Dashboard() {
  return (
    <Web3ReactManager>
    <DashboardWrapper>
    <div id="root">
      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <Grid item xs={12}>
	  <Card id="customcard">
            <Prediction />
	  </Card>
	  </Grid>
	  <Divider id="divider" />
          <Grid item xs={12}>
	  <Card id="customcard">
              <Price />
	  </Card>
	  </Grid>
        </Grid>
        <Grid item xs={12} md={8}>
	  <Card id="customcardForChart">
              <Chart />
	  </Card>
        </Grid>
      </Grid>
    </div>
    </DashboardWrapper>
    </Web3ReactManager>
  );
}

