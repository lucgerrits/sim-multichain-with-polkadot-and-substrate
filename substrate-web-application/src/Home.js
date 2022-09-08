import React from 'react'
import {
  Container,
  Grid,
} from 'semantic-ui-react'
import 'semantic-ui-css/semantic.min.css'

import { useSubstrateState } from './substrate-lib'
import { DeveloperConsole } from './substrate-lib/components'

import Balances from './Balances'
import BlockNumber from './BlockNumber'
import Events from './Events'
import Interactor from './Interactor'
import Metadata from './Metadata'
import NodeInfo from './NodeInfo'
import TemplateModule from './TemplateModule'
import Transfer from './Transfer'
import Upgrade from './Upgrade'
import NotConnected from './NotConnected'

function Main(props) {

  return (
    <div>
      <Container>
        <Grid stackable columns="equal">
          <Grid.Row stretched>
            <NodeInfo />
            <Metadata />
            <BlockNumber />
            <BlockNumber finalized />
          </Grid.Row>
          <Grid.Row stretched>
            <Balances />
          </Grid.Row>
          <Grid.Row>
            <Transfer />
            <Upgrade />
          </Grid.Row>
          <Grid.Row>
            <Interactor />
            <Events />
          </Grid.Row>
          <Grid.Row>
            <TemplateModule />
          </Grid.Row>
        </Grid>
      </Container>
      <DeveloperConsole />
    </div>
  )
}

export default function Home(props) {
    const { api } = useSubstrateState()
    return api.rpc && api.rpc.state ? (
        <Main {...props} />
    ) : <NotConnected />
  }
  