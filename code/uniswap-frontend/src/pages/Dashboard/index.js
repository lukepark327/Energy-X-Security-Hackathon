import React, { PureComponent } from 'react';
import styled from 'styled-components'
import Chart from './Chart.js'
import CustomCardContents from './CustomCardContents.js'

import { makeStyles } from '@material-ui/core/styles';
import { createMuiTheme, ThemeProvider } from '@material-ui/core/styles';
import { green, orange } from '@material-ui/core/colors';
import Divider from '@material-ui/core/Divider';
import Grid from '@material-ui/core/Grid';

import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';

const DashboardWrapper = styled.div`
  #root {
    flexGrow: 1;
  }

  #divider {
    margin: 12px 0 12px 0;
    background-color: ${({ theme }) => theme.chaliceGray};
  }

  #customcard {
    padding: 8px 8px 0 8px;
    background-color: ${({ theme }) => theme.concreteGray};
  }

  #customcardForChart {
    padding: 8px 20px 0 0;
    background-color: ${({ theme }) => theme.concreteGray};
  }
`

export default function Dashboard() {
  return (
    <DashboardWrapper>
    <div id="root">
      <Grid container spacing={3}>
        <Grid item xs={6}>
          <Grid item xs={12}>
	  <Card id="customcard">
            <CardContent>
              <CustomCardContents />
	    </CardContent>
	  </Card>
	  </Grid>
	  <Divider id="divider" />
          <Grid item xs={12}>
	  <Card id="customcard">
            <CardContent>
              <CustomCardContents />
	    </CardContent>
	  </Card>
	  </Grid>
        </Grid>
        <Grid item xs={6}>
	  <Card id="customcardForChart">
            <CardContent>
              <Chart />
	    </CardContent>
	  </Card>
        </Grid>
      </Grid>
    </div>
    </DashboardWrapper>
  );
}

