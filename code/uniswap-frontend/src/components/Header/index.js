import React from 'react'
import styled from 'styled-components'

import { Link } from '../../theme'
import Web3Status from '../Web3Status'
import OffCanvas from '../OffCanvas'
import { darken } from 'polished'

const HeaderFrame = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
`

const HeaderElement8 = styled.div`
  margin: 1.25rem;
  display: flex;
  width: 66%;
  display: flex;
  align-items: center;
`

const HeaderElement2 = styled.div`
  margin: 1.25rem;
  display: flex;
  width: 17%;
  display: flex;
  align-items: center;
`

const Nod = styled.span`
  transform: rotate(0deg);
  transition: transform 150ms ease-out;

  :hover {
    transform: rotate(-10deg);
  }
`

const Title = styled.div`
  width: 100%;
  display: flex;
  align-items: center;

  #link {
    text-decoration-color: ${({ theme }) => theme.UniswapPink};
  }

  #title {
    font-family: 'Nunito', sans-serif;
    display: inline;
    font-size: 2rem;
    font-weight: 900;
    color: ${({ theme }) => theme.wisteriaPurple};
    :hover {
      color: ${({ theme }) => darken(0.1, theme.wisteriaPurple)};
    }
  }

  #wrapper {
    width: 100%;
    text-align: center;
    font-size: 2rem;
  }
`

export default function Header() {
  return (
    <HeaderFrame>
      <HeaderElement2>
        <OffCanvas />
      </HeaderElement2>
      <HeaderElement8>
        <Title>
          <div id="wrapper">
            <Nod>
              <Link id="link" href="/">
                <span role="img" aria-label="unicorn">
                  ⚡️{'  '}
                </span>
              </Link>
            </Nod>
            <Link id="link" href="/">
	      <h1 id="title">AOMG</h1>
            </Link>
	  </div>
        </Title>
      </HeaderElement8>
      <HeaderElement2>
        <Web3Status />
      </HeaderElement2>
    </HeaderFrame>
  )
}
