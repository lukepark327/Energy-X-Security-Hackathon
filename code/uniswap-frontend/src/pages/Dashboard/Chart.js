import React, { PureComponent } from 'react';
import styled from 'styled-components'
import {
  ResponsiveContainer, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend,
} from 'recharts';

const data = [
  {
    name: '00h', Demand: 4000, Supply: 4300, amt: 2400,
  },
  {
    name: '03h', Demand: 3000, Supply: 3998, amt: 2210,
  },
  {
    name: '06h', Demand: 2000, Supply: 2500, amt: 2290,
  },
  {
    name: '09h', Demand: 2780, Supply: 3908, amt: 2000,
  },
  {
    name: '12h', Demand: 1890, Supply: 4800, amt: 2181,
  },
  {
    name: '15h', Demand: 2390, Supply: 3300, amt: 2500,
  },
  {
    name: '18h', Demand: 3490, Supply: 4300, amt: 2100,
  },
];

const ChartWrapper = styled.div`
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 65vh;
  justify-content: flex-start;
  align-items: center;
  flex: 1;
  overflow: auto;

  .recharts-legend-item-text {
    color: ${({ theme }) => theme.chaliceGray};
  }
`

export default class Chart extends PureComponent {
  static jsfiddleUrl = 'https://jsfiddle.net/alidingling/xqjtetw0/';

  render() {
    return (
      <ChartWrapper>
      <ResponsiveContainer width="100%" height="100%">
      <LineChart
        data={data}
        margin={{
          top: 5, right: 30, left: 20, bottom: 5,
        }}
      >
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip />
        <Legend />
        <Line type="monotone" dataKey="Supply" stroke="#8884d8" activeDot={{ r: 8 }} />
        <Line type="monotone" dataKey="Demand" stroke="#82ca9d" />
      </LineChart>
      </ResponsiveContainer>
      </ChartWrapper>
    );
  }
}

